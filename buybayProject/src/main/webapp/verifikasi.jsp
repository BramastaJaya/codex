<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, java.time.*, java.time.temporal.ChronoUnit" %>
<%
    // Cek admin
    if (session == null || session.getAttribute("role") == null || !session.getAttribute("role").equals("Admin")) {
        response.sendRedirect("index.html");
        return;
    }

    // Pagination logic
    int dataPerPage = 5;
    String pageParam = request.getParameter("page");
    int pageNum = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
    int offset = (pageNum - 1) * dataPerPage;
    int totalData = 0;
    int totalPages = 1;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/buybay-database", "root", ""
        );
        // Hitung total data
        String countSql = "SELECT COUNT(*) FROM pinjaman WHERE status = 'pending'";
        PreparedStatement countPs = conn.prepareStatement(countSql);
        ResultSet countRs = countPs.executeQuery();
        if (countRs.next()) {
            totalData = countRs.getInt(1);
            totalPages = (int)Math.ceil((double)totalData / dataPerPage);
            if (totalPages == 0) totalPages = 1;
        }
        countRs.close();
        countPs.close();
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Verifikasi Pinjaman - BuyBay Admin</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <style>
    body { background-color: #f8f9fa; font-family: 'Segoe UI', sans-serif; }
    .sidebar { background-color: #007bff; min-height: 100vh; color: white; }
    .sidebar a { display: block; padding: 10px 15px; color: white; text-decoration: none; }
    .sidebar a:hover { background-color: #0056b3; }
    .card-custom { border-radius: 16px; box-shadow: 0 0 12px rgba(0,0,0,0.1); }
  </style>
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <div class="col-md-2 sidebar p-3">
      <h4 class="text-white">BuyBay Admin</h4>
      <a href="admin_dashboard.jsp">🏠 Dashboard</a>
      <a href="verifikasi.jsp">📋 Verifikasi</a>
      <a href="pinjaman.jsp">🧾 Lihat Pinjaman</a>
      <a href="monitoring.jsp">👤 Monitoring</a>
      <a href="contact_customer.jsp">📧 Kontak Pelanggan</a>
      <a href="index.html" onclick="return confirm('Logout dari aplikasi?')">🚪 Logout</a>
    </div>

    <!-- Main Content -->
    <div class="col-md-10 p-4">
      <h2>Verifikasi Pengajuan Pinjaman</h2>
      <div class="card card-custom p-4 mt-3">
        <div class="table-responsive">
        <table class="table table-bordered">
          <thead>
            <tr>
              <th>Nama Customer</th>
              <th>Jumlah</th>
              <th>Tenor</th>
              <th>Tanggal Pengajuan</th>
              <th>Status</th>
              <th>Tujuan Pengajuan</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            <%
              String sql = "SELECT p.pinjaman_id, u.nama_lengkap, p.jumlah_pinjaman, p.tanggal_pengajuan, p.tanggal_jatuh_tempo, p.status, p.tujuan " +
                           "FROM pinjaman p JOIN customer c ON p.customer_id = c.customer_id " +
                           "JOIN user u ON c.user_id = u.user_id WHERE p.status = 'pending' ORDER BY p.tanggal_pengajuan DESC LIMIT ? OFFSET ?";
              PreparedStatement ps = conn.prepareStatement(sql);
              ps.setInt(1, dataPerPage);
              ps.setInt(2, offset);
              ResultSet rs = ps.executeQuery();
              boolean hasData = false;
              while (rs.next()) {
                  hasData = true;
                  int pinjamanId = rs.getInt("pinjaman_id");
                  String namaCustomer = rs.getString("nama_lengkap");
                  String jumlah = String.format("Rp %,d", rs.getLong("jumlah_pinjaman"));
                  java.sql.Date tglPengajuan = rs.getDate("tanggal_pengajuan");
                  java.sql.Date tglJatuhTempo = rs.getDate("tanggal_jatuh_tempo");
                  String status = rs.getString("status");
                  String tujuan = rs.getString("tujuan");
                  String tenor = "-";
                  if (tglPengajuan != null && tglJatuhTempo != null) {
                      LocalDate mulai = tglPengajuan.toLocalDate();
                      LocalDate akhir = tglJatuhTempo.toLocalDate();
                      long bulan = ChronoUnit.MONTHS.between(mulai, akhir);
                      tenor = bulan + " Bulan";
                  }
            %>
            <tr>
              <td><%= namaCustomer %></td>
              <td><%= jumlah %></td>
              <td><%= tenor %></td>
              <td><%= tglPengajuan %></td>
              <td><span class="badge bg-warning text-dark">Menunggu</span></td>
              <td><%= tujuan %></td>
              <td>
                <form method="post" action="VerifikasiPinjamanServlet" style="display:inline;">
                  <input type="hidden" name="pinjaman_id" value="<%= pinjamanId %>"/>
                  <button type="submit" name="aksi" value="accept" class="btn btn-success btn-sm">✔ Terima</button>
                </form>
                <form method="post" action="VerifikasiPinjamanServlet" style="display:inline;">
                  <input type="hidden" name="pinjaman_id" value="<%= pinjamanId %>"/>
                  <button type="submit" name="aksi" value="reject" class="btn btn-danger btn-sm">✖ Tolak</button>
                </form>
              </td>
            </tr>
            <%
              }
              if (!hasData) {
            %>
              <tr>
                <td colspan="7" class="text-center text-muted">Belum ada pengajuan pinjaman yang perlu diverifikasi.</td>
              </tr>
            <%
              }
              rs.close();
              ps.close();
              conn.close();
            } catch (Exception e) {
            %>
            <tr>
              <td colspan="7" class="text-danger">Terjadi error: <%= e.getMessage() %></td>
            </tr>
            <%
            }
            %>
          </tbody>
        </table>
        </div>
        <!-- PAGINATION CONTROL -->
        <nav>
          <ul class="pagination justify-content-center mt-3">
            <li class="page-item <%= (pageNum <= 1) ? "disabled" : "" %>">
              <a class="page-link" href="verifikasi.jsp?page=<%= pageNum - 1 %>">Prev</a>
            </li>
            <% for (int i = 1; i <= totalPages; i++) { %>
              <li class="page-item <%= (i == pageNum) ? "active" : "" %>">
                <a class="page-link" href="verifikasi.jsp?page=<%= i %>"><%= i %></a>
              </li>
            <% } %>
            <li class="page-item <%= (pageNum >= totalPages) ? "disabled" : "" %>">
              <a class="page-link" href="verifikasi.jsp?page=<%= pageNum + 1 %>">Next</a>
            </li>
          </ul>
        </nav>
      </div>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

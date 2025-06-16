<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale, java.time.*, java.time.temporal.ChronoUnit, java.math.BigDecimal" %>
<%
    // Cek session admin
    if (session == null || session.getAttribute("role") == null || !session.getAttribute("role").equals("Admin")) {
        response.sendRedirect("index.html");
        return;
    }
    String namaAdmin = (String) session.getAttribute("nama_admin");
    int userId = (session.getAttribute("user_id") != null) ? (Integer) session.getAttribute("user_id") : 0;

    // Format Rupiah
    Locale indo = new Locale("id", "ID");
    NumberFormat formatRupiah = NumberFormat.getCurrencyInstance(indo);

    // Pagination
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

        // Info admin
        String adminQuery = "SELECT * FROM user WHERE user_id = ?";
        PreparedStatement adminPs = conn.prepareStatement(adminQuery);
        adminPs.setInt(1, userId);
        ResultSet adminRs = adminPs.executeQuery();
        String ktpId = "", jenisKelamin = "", noTelp = "";
        if (adminRs.next()) {
            ktpId = adminRs.getString("ktp_id");
            jenisKelamin = adminRs.getString("jenis_kelamin");
            noTelp = adminRs.getString("no_telp");
        }
        adminRs.close();
        adminPs.close();

        // Statistik
        Statement statSt = conn.createStatement();
        ResultSet pengajuanRs = statSt.executeQuery("SELECT COUNT(*) FROM pinjaman");
        int totalPengajuan = (pengajuanRs.next()) ? pengajuanRs.getInt(1) : 0;
        pengajuanRs.close();

        ResultSet customerRs = statSt.executeQuery("SELECT COUNT(*) FROM customer");
        int jumlahCustomer = (customerRs.next()) ? customerRs.getInt(1) : 0;
        customerRs.close();

        // --- Query Total Transaksi dengan format BigDecimal ---
        ResultSet transaksiRs = statSt.executeQuery("SELECT IFNULL(SUM(jumlah_pembayaran),0) FROM transaksi");
        BigDecimal totalTransaksi = BigDecimal.ZERO;
        if (transaksiRs.next()) {
            totalTransaksi = transaksiRs.getBigDecimal(1);
            if (totalTransaksi == null) totalTransaksi = BigDecimal.ZERO;
        }
        transaksiRs.close();
        statSt.close();

        // -- Pagination pinjaman pending --
        String countSql = "SELECT COUNT(*) FROM pinjaman WHERE status = 'pending'";
        PreparedStatement countPs = conn.prepareStatement(countSql);
        ResultSet countRs = countPs.executeQuery();
        if (countRs.next()) {
            totalData = countRs.getInt(1);
            totalPages = (int) Math.ceil((double) totalData / dataPerPage);
            if (totalPages == 0) totalPages = 1;
        }
        countRs.close();
        countPs.close();
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Admin - BuyBay</title>
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
    <!-- Sidebar Admin -->
    <div class="col-md-2 sidebar p-3">
      <h4 class="text-white">BuyBay Admin</h4>
      <a href="admin_dashboard.jsp">🏠 Dashboard</a>
      <a href="verifikasi.jsp">📋 Verifikasi</a>
      <a href="pinjaman.jsp">🧾 Lihat Pinjaman</a>
      <a href="monitoring.jsp">👤 Monitoring</a>
      <a href="contact_customer.jsp">📧 Kontak Pelanggan</a>
      <a href="index.html" onclick="return confirm('Logout dari aplikasi?')">🚪 Logout</a>
    </div>

    <!-- Konten Utama -->
    <div class="col-md-10 p-4">
      <h2 class="mb-4">Selamat Datang Admin, <%= namaAdmin %>!</h2>
      <p><strong>ID:</strong> <%= ktpId %></p>
      <p><strong>Jenis Kelamin:</strong> <%= jenisKelamin %></p>
      <p><strong>Nomor Telepon:</strong> <%= noTelp %></p>

      <div class="row mb-4 mt-4">
        <div class="col-md-4">
          <div class="card card-custom p-3">
            <h5>Total Pengajuan</h5>
            <p><%= totalPengajuan %> pengajuan baru</p>
          </div>
        </div>
        <div class="col-md-4">
          <div class="card card-custom p-3">
            <h5>Jumlah Customer</h5>
            <p><%= jumlahCustomer %> pengguna aktif</p>
          </div>
        </div>
        <div class="col-md-4">
          <div class="card card-custom p-3">
            <h5>Total Transaksi</h5>
            <p><%= formatRupiah.format(totalTransaksi) %></p>
          </div>
        </div>
      </div>

      <div class="card card-custom p-4">
        <h4 class="mb-3">Verifikasi Pinjaman (Pending)</h4>
        <div class="table-responsive">
          <table class="table table-bordered">
            <thead class="table-light">
              <tr>
                <th>No</th>
                <th>Nama</th>
                <th>Jumlah</th>
                <th>Tanggal Pengajuan</th>
                <th>Jatuh Tempo</th>
                <th>Status</th>
                <th>Aksi</th>
              </tr>
            </thead>
            <tbody>
              <%
                String sql = "SELECT p.pinjaman_id, u.nama_lengkap, p.jumlah_pinjaman, p.tanggal_pengajuan, p.tanggal_jatuh_tempo, p.status " +
                             "FROM pinjaman p JOIN customer c ON p.customer_id = c.customer_id " +
                             "JOIN user u ON c.user_id = u.user_id WHERE p.status = 'pending' " +
                             "ORDER BY p.tanggal_pengajuan DESC LIMIT ? OFFSET ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, dataPerPage);
                ps.setInt(2, offset);
                ResultSet rs = ps.executeQuery();
                int no = offset + 1;
                boolean hasData = false;
                while (rs.next()) {
                    hasData = true;
              %>
              <tr>
                <td><%= no++ %></td>
                <td><%= rs.getString("nama_lengkap") %></td>
                <td><%= formatRupiah.format(rs.getBigDecimal("jumlah_pinjaman")) %></td>
                <td><%= rs.getDate("tanggal_pengajuan") %></td>
                <td><%= rs.getDate("tanggal_jatuh_tempo") %></td>
                <td><span class="badge bg-warning text-dark">Menunggu</span></td>
                <td>
                  <form method="post" action="VerifikasiPinjamanServlet" style="display:inline;">
                    <input type="hidden" name="pinjaman_id" value="<%= rs.getInt("pinjaman_id") %>"/>
                    <button type="submit" name="aksi" value="accept" class="btn btn-success btn-sm">✔ Terima</button>
                  </form>
                  <form method="post" action="VerifikasiPinjamanServlet" style="display:inline;">
                    <input type="hidden" name="pinjaman_id" value="<%= rs.getInt("pinjaman_id") %>"/>
                    <button type="submit" name="aksi" value="reject" class="btn btn-danger btn-sm">✖ Tolak</button>
                  </form>
                </td>
              </tr>
              <%
                }
                if (!hasData) {
              %>
                <tr>
                  <td colspan="7" class="text-center text-muted">Tidak ada pengajuan pinjaman pending.</td>
                </tr>
              <%
                }
                rs.close();
                ps.close();
                conn.close();
              %>
            </tbody>
          </table>
        </div>
        <!-- PAGINATION CONTROL -->
        <nav>
          <ul class="pagination justify-content-center mt-3">
            <li class="page-item <%= (pageNum <= 1) ? "disabled" : "" %>">
              <a class="page-link" href="admin_dashboard.jsp?page=<%= pageNum - 1 %>">Prev</a>
            </li>
            <% for (int i = 1; i <= totalPages; i++) { %>
              <li class="page-item <%= (i == pageNum) ? "active" : "" %>">
                <a class="page-link" href="admin_dashboard.jsp?page=<%= i %>"><%= i %></a>
              </li>
            <% } %>
            <li class="page-item <%= (pageNum >= totalPages) ? "disabled" : "" %>">
              <a class="page-link" href="admin_dashboard.jsp?page=<%= pageNum + 1 %>">Next</a>
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
<%
    } catch (Exception e) {
%>
  <tr>
    <td colspan="7" class="text-danger">Terjadi error: <%= e.getMessage() %></td>
  </tr>
<%
    }
%>

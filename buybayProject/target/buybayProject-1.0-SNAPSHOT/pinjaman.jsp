<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.time.*, java.time.temporal.ChronoUnit, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<% 
    Locale indo = new Locale("id","ID");
    NumberFormat formatRupiah = NumberFormat.getCurrencyInstance(indo);

    // Pagination variables
    int dataPerPage = 5;
    String pageParam = request.getParameter("page");
    int pageNum = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
    int offset = (pageNum - 1) * dataPerPage;
    int totalData = 0;
    int totalPages = 1;

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/buybay-database", "root", ""
    );
    String countSql = "SELECT COUNT(*) FROM pinjaman WHERE status = 'accepted'";
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

<%
    if (session == null || session.getAttribute("role") == null || !session.getAttribute("role").equals("Admin")) {
        response.sendRedirect("index.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Pinjaman Disetujui - BuyBay Admin</title>
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
            <h2>Daftar Pinjaman Disetujui</h2>
            <div class="card card-custom p-4 mt-3">
                <div class="table-responsive">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>No</th>
                                <th>Nama Customer</th>
                                <th>Jumlah per Bulan</th>
                                <th>Bunga (%)</th>
                                <th>Jumlah per Bulan (+Bunga)</th>
                                <th>Sisa Tenor</th>
                                <th>Jatuh Tempo</th>
                                <th>Sisa Pembayaran</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    String sql = "SELECT p.pinjaman_id, u.nama_lengkap, p.jumlah_pinjaman, p.tanggal_pengajuan, p.tanggal_jatuh_tempo, p.bunga " +
                                                 "FROM pinjaman p JOIN customer c ON p.customer_id = c.customer_id " +
                                                 "JOIN user u ON c.user_id = u.user_id " +
                                                 "WHERE p.status = 'accepted' ORDER BY p.tanggal_pengajuan DESC LIMIT ? OFFSET ?";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setInt(1, dataPerPage);
                                    ps.setInt(2, offset);
                                    ResultSet rs = ps.executeQuery();
                                    int no = offset + 1;
                                    boolean hasData = false;
                                    while (rs.next()) {
                                        hasData = true;
                                        String nama = rs.getString("nama_lengkap");
                                        BigDecimal jumlahPinjaman = rs.getBigDecimal("jumlah_pinjaman");
                                        java.sql.Date tglPengajuan = rs.getDate("tanggal_pengajuan");
                                        java.sql.Date tglJatuhTempo = rs.getDate("tanggal_jatuh_tempo");
                                        BigDecimal bunga = rs.getBigDecimal("bunga");
                                        if (bunga == null){
                                            bunga = new BigDecimal("2.05");
                                        }
                                        int totalTenor = 1;
                                        if (tglPengajuan != null && tglJatuhTempo != null) {
                                            LocalDate mulai = tglPengajuan.toLocalDate();
                                            LocalDate akhir = tglJatuhTempo.toLocalDate();
                                            totalTenor = (int) ChronoUnit.MONTHS.between(mulai, akhir);
                                            if (totalTenor < 1) totalTenor = 1;
                                        }
                                        // Hitung pembayaran per bulan (tanpa bunga)
                                        BigDecimal perBulan = jumlahPinjaman.divide(new BigDecimal(totalTenor), 2, java.math.RoundingMode.HALF_UP);
                                        // Hitung pembayaran per bulan setelah bunga
                                        BigDecimal bungaNominal = jumlahPinjaman.multiply(bunga.divide(new BigDecimal("100")));
                                        BigDecimal totalSetelahBunga = jumlahPinjaman.add(bungaNominal);
                                        BigDecimal perBulanBunga = totalSetelahBunga.divide(new BigDecimal(totalTenor), 2, java.math.RoundingMode.HALF_UP);
                                        // Hitung sisa tenor (bulan dari sekarang ke jatuh tempo)
                                        String sisaTenor = "-";
                                        if (tglJatuhTempo != null) {
                                            LocalDate sekarang = LocalDate.now();
                                            LocalDate jatuhTempo = tglJatuhTempo.toLocalDate();
                                            long bulanSisa = ChronoUnit.MONTHS.between(sekarang, jatuhTempo);
                                            sisaTenor = (bulanSisa > 0) ? bulanSisa + " bulan" : "Lunas";
                                        }
                                        // Hitung sisa pembayaran
                                        // (anggap belum ada pembayaran = totalSetelahBunga)
                                        BigDecimal sisaPembayaran = totalSetelahBunga;
                            %>
                            <tr>
                                <td><%= no++ %></td>
                                <td><%= nama %></td>
                                <td><%= formatRupiah.format(perBulan) %></td>
                                <td><%= bunga.setScale(2, java.math.RoundingMode.HALF_UP).toPlainString() %>%</td>
                                <td><%= formatRupiah.format(perBulanBunga) %></td>
                                <td><%= sisaTenor %></td>
                                <td><%= tglJatuhTempo %></td>
                                <td><%= formatRupiah.format(sisaPembayaran) %></td>
                            </tr>
                            <%
                                    }
                                    if (!hasData) {
                            %>
                            <tr>
                                <td colspan="8" class="text-center text-muted">Belum ada pinjaman yang disetujui.</td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    ps.close();
                                    conn.close();
                                } catch (Exception e) {
                            %>
                            <tr>
                                <td colspan="8" class="text-danger">Terjadi error: <%= e.getMessage() %></td>
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
                      <a class="page-link" href="pinjaman.jsp?page=<%= pageNum - 1 %>">Prev</a>
                    </li>
                    <% for (int i = 1; i <= totalPages; i++) { %>
                      <li class="page-item <%= (i == pageNum) ? "active" : "" %>">
                        <a class="page-link" href="pinjaman.jsp?page=<%= i %>"><%= i %></a>
                      </li>
                    <% } %>
                    <li class="page-item <%= (pageNum >= totalPages) ? "disabled" : "" %>">
                      <a class="page-link" href="pinjaman.jsp?page=<%= pageNum + 1 %>">Next</a>
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

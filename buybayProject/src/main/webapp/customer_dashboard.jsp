<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*, java.text.NumberFormat, java.util.Locale, java.math.BigDecimal" %>
<%
    // Proteksi login customer
    if (session == null || session.getAttribute("role") == null || !"customer".equals(session.getAttribute("role"))) {
        response.sendRedirect("index.html");
        return;
    }
    int userId = (session.getAttribute("user_id") != null) ? (Integer) session.getAttribute("user_id") : -1;
    if (userId == -1) {
        response.sendRedirect("index.html");
        return;
    }

    String nama = "", email = "", noTelp = "", jenisKelamin = "", ktpId = "";
    BigDecimal saldo = BigDecimal.ZERO;
    BigDecimal limitBulanan = BigDecimal.ZERO;
    int customerId = -1;

    // Format Rupiah
    Locale indo = new Locale("id", "ID");
    NumberFormat formatRupiah = NumberFormat.getCurrencyInstance(indo);

    // Ambil data customer & user
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/buybay-database", "root", ""
        );
        // Ambil data user dan customer sekaligus
        String sql = "SELECT u.nama_lengkap, u.email, u.no_telp, u.jenis_kelamin, u.ktp_id, c.customer_id, c.saldo, c.limit_bulanan " +
                     "FROM user u JOIN customer c ON u.user_id = c.user_id WHERE u.user_id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            nama = rs.getString("nama_lengkap");
            email = rs.getString("email");
            noTelp = rs.getString("no_telp");
            jenisKelamin = rs.getString("jenis_kelamin");
            ktpId = rs.getString("ktp_id");
            customerId = rs.getInt("customer_id");
            saldo = rs.getBigDecimal("saldo");
            limitBulanan = rs.getBigDecimal("limit_bulanan");
        }
        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        // Bisa tampilkan pesan error jika perlu
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Dashboard Customer - BuyBay</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <style>
      body { background-color: #f8f9fa; font-family: 'Segoe UI', sans-serif; }
      .sidebar { background-color: #007bff; min-height: 100vh; color: white; }
      .sidebar a { display: block; padding: 10px 15px; color: white; text-decoration: none; }
      .sidebar a:hover { background-color: #0056b3; }
      .card-custom { border-radius: 16px; box-shadow: 0 0 12px rgba(0,0,0,0.08); }
    </style>
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-2 sidebar p-3">
            <h4 class="text-white">BuyBay Customer</h4>
            <a href="dashboard_customer.jsp">🏠 Dashboard</a>
            <a href="ajukan_pinjaman.jsp">📝 Ajukan Pinjaman</a>
            <a href="riwayat_pinjaman.jsp">📃 Riwayat Pinjaman</a>
            <a href="tagihan.jsp">💳 Tagihan</a>
            <a href="inbox_customer.jsp">✉️ Inbox</a>
            <a href="logout.jsp" onclick="return confirm('Logout dari aplikasi?')">🚪 Logout</a>
        </div>
        <!-- Main Content -->
        <div class="col-md-10 p-4">
            <h2 class="mb-4">Selamat Datang, <%= nama %>!</h2>
            <div class="mb-3">
                <strong>Email:</strong> <%= email %><br>
                <strong>No. Telepon:</strong> <%= noTelp %>
            </div>
            <div class="row mb-4">
                <div class="col-md-4">
                    <div class="card card-custom p-3">
                        <h6>Saldo Saat Ini</h6>
                        <h4 class="text-primary"><%= formatRupiah.format(saldo) %></h4>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card card-custom p-3">
                        <h6>Limit Bulanan</h6>
                        <h4 class="text-success"><%= formatRupiah.format(limitBulanan) %></h4>
                    </div>
                </div>
            </div>
            <hr>
            <h5>Tagihan & Pinjaman</h5>
            <div class="table-responsive">
                <table class="table table-bordered mt-3">
                    <thead>
                        <tr>
                            <th>Nama Perusahaan</th>
                            <th>Kategori Tagihan</th>
                            <th>Status Tagihan</th>
                            <th>Jatuh Tempo</th>
                            <th>Jumlah</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection conn2 = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/buybay-database", "root", ""
                            );
                            String sqlTagihan = "SELECT nama_perusahaan, kategori_tagihan, status, tanggal_notifikasi, jumlah " +
                                                "FROM tagihan WHERE customer_id = ? ORDER BY tanggal_notifikasi ASC";
                            PreparedStatement psTagihan = conn2.prepareStatement(sqlTagihan);
                            psTagihan.setInt(1, customerId);
                            ResultSet rsTagihan = psTagihan.executeQuery();
                            boolean hasTagihan = false;
                            while (rsTagihan.next()) {
                                hasTagihan = true;
                        %>
                        <tr>
                            <td><%= rsTagihan.getString("nama_perusahaan") %></td>
                            <td><%= rsTagihan.getString("kategori_tagihan") %></td>
                            <td>
                                <% String status = rsTagihan.getString("status"); %>
                                <% if ("Lunas".equalsIgnoreCase(status)) { %>
                                    <span class="badge bg-success">Lunas</span>
                                <% } else if ("Belum Lunas".equalsIgnoreCase(status)) { %>
                                    <span class="badge bg-warning text-dark">Belum Lunas</span>
                                <% } else if ("Menunggak".equalsIgnoreCase(status)) { %>
                                    <span class="badge bg-danger">Menunggak</span>
                                <% } else { %>
                                    <span class="badge bg-secondary"><%= status %></span>
                                <% } %>
                            </td>
                            <td><%= rsTagihan.getDate("tanggal_notifikasi") %></td>
                            <td><%= formatRupiah.format(rsTagihan.getBigDecimal("jumlah")) %></td>
                        </tr>
                        <%
                            }
                            if (!hasTagihan) {
                        %>
                        <tr>
                            <td colspan="5" class="text-center text-muted">Belum ada tagihan untuk ditampilkan.</td>
                        </tr>
                        <%
                            }
                            rsTagihan.close();
                            psTagihan.close();
                            conn2.close();
                        } catch(Exception e) {
                        %>
                        <tr>
                            <td colspan="5" class="text-danger">Terjadi error: <%= e.getMessage() %></td>
                        </tr>
                        <%
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

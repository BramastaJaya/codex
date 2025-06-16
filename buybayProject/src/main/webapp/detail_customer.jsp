<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%
    if (session == null || session.getAttribute("role") == null || !session.getAttribute("role").equals("Admin")) {
        response.sendRedirect("index.html");
        return;
    }
    String customerIdParam = request.getParameter("customer_id");
    int customerId = (customerIdParam != null) ? Integer.parseInt(customerIdParam) : -1;

    String nama = "", email = "", noTelp = "", alamat = "", tanggalLahir = "", jenisKelamin = "", ktpId = "";

    // --- Format Rupiah ---
    Locale indo = new Locale("id", "ID");
    NumberFormat formatRupiah = NumberFormat.getCurrencyInstance(indo);

    // --- Ambil Total Transaksi ---
    BigDecimal totalTransaksi = BigDecimal.ZERO;
    if (customerId != -1) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connTotal = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/buybay-database", "root", ""
            );
            String sqlTrans = "SELECT SUM(jumlah_pembayaran) AS total_transaksi FROM transaksi WHERE customer_id = ?";
            PreparedStatement psTrans = connTotal.prepareStatement(sqlTrans);
            psTrans.setInt(1, customerId);
            ResultSet rsTrans = psTrans.executeQuery();
            if (rsTrans.next() && rsTrans.getBigDecimal("total_transaksi") != null) {
                totalTransaksi = rsTrans.getBigDecimal("total_transaksi");
            }
            rsTrans.close();
            psTrans.close();
            connTotal.close();
        } catch(Exception e) {
            // Handle error jika perlu
        }
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Detail Customer - BuyBay Admin</title>
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
            <h2>Detail Customer</h2>
            <div class="card card-custom p-4 mb-4">
            <%
                if (customerId == -1) {
            %>
                <p class="text-danger">Customer tidak ditemukan.</p>
            <%
                } else {
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection conn = DriverManager.getConnection(
                            "jdbc:mysql://localhost:3306/buybay-database", "root", ""
                        );
                        String sql = "SELECT u.nama_lengkap, u.email, u.no_telp, u.alamat_domisili, u.tanggal_lahir, u.jenis_kelamin, u.ktp_id " +
                                     "FROM customer c JOIN user u ON c.user_id = u.user_id WHERE c.customer_id = ?";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ps.setInt(1, customerId);
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            nama = rs.getString("nama_lengkap");
                            email = rs.getString("email");
                            noTelp = rs.getString("no_telp");
                            alamat = rs.getString("alamat_domisili");
                            tanggalLahir = (rs.getDate("tanggal_lahir") != null) ? rs.getDate("tanggal_lahir").toString() : "";
                            jenisKelamin = rs.getString("jenis_kelamin");
                            ktpId = rs.getString("ktp_id");
                        }
                        rs.close();
                        ps.close();
            %>
                <h4><%= nama %></h4>
                <p><strong>Email:</strong> <%= email %></p>
                <p><strong>No. Telepon:</strong> <%= noTelp %></p>
                <p><strong>Alamat:</strong> <%= alamat %></p>
                <p><strong>Tanggal Lahir:</strong> <%= tanggalLahir %></p>
                <p><strong>Jenis Kelamin:</strong> <%= jenisKelamin %></p>
                <p><strong>No. KTP:</strong> <%= ktpId %></p>
                <p><strong>Total Transaksi:</strong> <%= formatRupiah.format(totalTransaksi) %></p>
            <%
                        // Riwayat pinjaman
                        out.println("<hr><h5>Riwayat Pinjaman</h5>");
                        String sqlPinjaman = "SELECT jumlah_pinjaman, tanggal_pengajuan, tanggal_jatuh_tempo, status, tujuan FROM pinjaman WHERE customer_id = ? ORDER BY tanggal_pengajuan DESC";
                        PreparedStatement psP = conn.prepareStatement(sqlPinjaman);
                        psP.setInt(1, customerId);
                        ResultSet rsP = psP.executeQuery();
                        boolean hasPinjaman = false;
            %>
                        <div class="table-responsive">
                        <table class="table table-bordered mt-3">
                            <thead>
                                <tr>
                                    <th>Jumlah</th>
                                    <th>Tanggal Pengajuan</th>
                                    <th>Tanggal Jatuh Tempo</th>
                                    <th>Tujuan</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
            <%
                        while (rsP.next()) {
                            hasPinjaman = true;
            %>
                            <tr>
                                <td><%= formatRupiah.format(rsP.getBigDecimal("jumlah_pinjaman")) %></td>
                                <td><%= rsP.getDate("tanggal_pengajuan") %></td>
                                <td><%= rsP.getDate("tanggal_jatuh_tempo") %></td>
                                <td><%= rsP.getString("tujuan") %></td>
                                <td>
                                    <% if ("accepted".equals(rsP.getString("status"))) { %>
                                        <span class="badge bg-success">Disetujui</span>
                                    <% } else if ("pending".equals(rsP.getString("status"))) { %>
                                        <span class="badge bg-warning text-dark">Pending</span>
                                    <% } else if ("rejected".equals(rsP.getString("status"))) { %>
                                        <span class="badge bg-danger">Ditolak</span>
                                    <% } else { %>
                                        <span class="badge bg-secondary"><%= rsP.getString("status") %></span>
                                    <% } %>
                                </td>
                            </tr>
            <%
                        }
                        if (!hasPinjaman) {
            %>
                            <tr>
                                <td colspan="5" class="text-center text-muted">Belum ada riwayat pinjaman.</td>
                            </tr>
            <%
                        }
                        rsP.close();
                        psP.close();

                        // ======================== INVOICE =========================
                        // Invoice hanya muncul jika ada pinjaman lunas
                        try {
                            Connection connInv = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/buybay-database", "root", ""
                            );
                            String sqlInv = "SELECT i.invoice_id, i.nomor_invoice, i.tanggal_pembayaran, i.jumlah, i.denda, " +
                                            "i.metode_pembayaran, i.atas_nama, i.deskripsi, t.pinjaman_id " +
                                            "FROM invoice i JOIN transaksi t ON i.transaksi_id = t.transaksi_id " +
                                            "JOIN pinjaman p ON t.pinjaman_id = p.pinjaman_id " +
                                            "WHERE i.customer_id = ? AND p.status_pelunasan = 'Lunas' " +
                                            "ORDER BY i.tanggal_pembayaran DESC";
                            PreparedStatement psInv = connInv.prepareStatement(sqlInv);
                            psInv.setInt(1, customerId);
                            ResultSet rsInv = psInv.executeQuery();
                            boolean hasInvoice = false;
            %>
                        <hr>
                        <h5>Daftar Invoice (Pinjaman Lunas)</h5>
                        <div class="table-responsive">
                          <table class="table table-bordered mt-3">
                            <thead>
                              <tr>
                                <th>No Invoice</th>
                                <th>Tanggal</th>
                                <th>Jumlah</th>
                                <th>Denda</th>
                                <th>Metode</th>
                                <th>Atas Nama</th>
                                <th>Deskripsi</th>
                                <th>Pinjaman ID</th>
                              </tr>
                            </thead>
                            <tbody>
                            <%
                            while (rsInv.next()) {
                                hasInvoice = true;
                            %>
                              <tr>
                                <td><%= rsInv.getString("nomor_invoice") %></td>
                                <td><%= rsInv.getDate("tanggal_pembayaran") %></td>
                                <td><%= formatRupiah.format(rsInv.getBigDecimal("jumlah")) %></td>
                                <td><%= formatRupiah.format(rsInv.getBigDecimal("denda")) %></td>
                                <td><%= rsInv.getString("metode_pembayaran") %></td>
                                <td><%= rsInv.getString("atas_nama") %></td>
                                <td><%= rsInv.getString("deskripsi") %></td>
                                <td><%= rsInv.getInt("pinjaman_id") %></td>
                              </tr>
                            <%
                            }
                            if (!hasInvoice) {
                            %>
                              <tr>
                                <td colspan="8" class="text-center text-muted">Belum ada invoice untuk pinjaman lunas.</td>
                              </tr>
                            <%
                            }
                            rsInv.close();
                            psInv.close();
                            connInv.close();
                        } catch (Exception e) {
                            // Gagal load invoice, bisa tampilkan pesan error jika mau
                        }
                        // ========================================================
                        conn.close();
                    } catch (Exception e) {
            %>
                        <p class="text-danger">Terjadi error: <%= e.getMessage() %></p>
            <%
                    }
                }
            %>
                            </tbody>
                        </table>
                        </div>
            </div>
            <a href="monitoring.jsp" class="btn btn-secondary">Kembali ke Monitoring</a>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

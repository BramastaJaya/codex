<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // Proteksi admin
    if (session == null || session.getAttribute("role") == null || !session.getAttribute("role").equals("Admin")) {
        response.sendRedirect("index.html");
        return;
    }

    // Ambil semua email customer untuk dropdown
    List<String[]> customers = new ArrayList<>();
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/buybay-database", "root", ""
    );
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT user.user_id, user.email, user.nama_lengkap FROM user JOIN customer ON user.user_id=customer.user_id");
    while(rs.next()) {
        customers.add(new String[]{ rs.getString("user_id"), rs.getString("email"), rs.getString("nama_lengkap") });
    }
    rs.close(); stmt.close(); conn.close();
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8"/>
    <title>Contact Customer - BuyBay Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <style>
      body { background-color: #f8f9fa; font-family: 'Segoe UI', sans-serif; }
      .sidebar { background-color: #007bff; min-height: 100vh; color: white; }
      .sidebar a { display: block; padding: 10px 15px; color: white; text-decoration: none; }
      .sidebar a:hover { background-color: #0056b3; }
      .card-custom { border-radius: 16px; box-shadow: 0 0 12px rgba(0,0,0,0.1); }
    </style>
    <script>
      function loadPinjaman() {
        var userId = document.getElementById('user_id').value;
        window.location.href = "contact_customer.jsp?user_id=" + userId;
      }
      function setKategoriMsg() {
        var kategori = document.getElementById('kategori').value;
        var isi = '';
        if (kategori == 'late') {
          isi = 'Peringatan: Anda memiliki tagihan pinjaman yang telah melewati tenggat pembayaran. Segera lakukan pembayaran untuk menghindari denda.';
        } else if (kategori == 'approved') {
          isi = 'Selamat! Pengajuan pinjaman Anda telah disetujui. Silakan cek detail pinjaman Anda di dashboard.';
        } else if (kategori == 'rejected') {
          isi = 'Mohon maaf, pengajuan pinjaman Anda belum dapat kami setujui. Silakan perbaiki data atau hubungi admin untuk info lebih lanjut.';
        } else if (kategori == 'reminder') {
          isi = 'Pengingat: Anda memiliki pinjaman yang akan jatuh tempo dalam waktu dekat. Pastikan pembayaran dilakukan tepat waktu.';
        }
        document.getElementById('isi').value = isi;
      }
      function showDetail(detail) {
        document.getElementById('pinjaman_detail').innerHTML = detail;
      }
    </script>
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
            <h2>Kontak Customer</h2>
            <div class="card card-custom p-4 mt-3">
                <% String succ = request.getParameter("success"); String err = request.getParameter("error"); %><% 
                if (succ != null) { %>
                    <div class="alert alert-success">Pesan berhasil dikirim!</div>
                    <% } 
                else if (err != null) { 
                    %>
                    <div class="alert alert-danger">Pesan gagal dikirim. Silakan ulangi.</div>
                    <% } %>
                <form method="post" action="ContactCustomerServlet">
                    <div class="mb-3">
                        <label for="user_id" class="form-label">Email Customer</label>
                        <select class="form-select" id="user_id" name="user_id" onchange="loadPinjaman()" required>
                            <option value="">-- Pilih Email --</option>
                            <% String selectedUser = request.getParameter("user_id");
                               for (String[] cust : customers) { %>
                               <option value="<%= cust[0] %>" <%= (selectedUser != null && selectedUser.equals(cust[0])) ? "selected" : "" %>>
                                   <%= cust[1] %> - <%= cust[2] %>
                               </option>
                            <% } %>
                        </select>
                    </div>
                    <%
                    // Jika customer sudah dipilih, tampilkan pinjaman
                    if (selectedUser != null && !selectedUser.isEmpty()) {
                        Connection conn2 = DriverManager.getConnection(
                            "jdbc:mysql://localhost:3306/buybay-database", "root", ""
                        );
                        PreparedStatement ps2 = conn2.prepareStatement(
                            "SELECT pinjaman_id, tanggal_jatuh_tempo, jumlah_pinjaman, status FROM pinjaman WHERE customer_id = (SELECT customer_id FROM customer WHERE user_id = ?) ORDER BY tanggal_jatuh_tempo DESC");
                        ps2.setString(1, selectedUser);
                        ResultSet rs2 = ps2.executeQuery();
                    %>
                    <div class="mb-3">
                        <label for="pinjaman_id" class="form-label">Pilih Pinjaman</label>
                        <select class="form-select" id="pinjaman_id" name="pinjaman_id" onchange="showDetail(this.options[this.selectedIndex].getAttribute('data-detail'))" required>
                            <option value="">-- Pilih Pinjaman --</option>
                            <% while(rs2.next()) { 
                                String detail = "Jumlah: Rp " + rs2.getLong("jumlah_pinjaman") +
                                                "<br>Status: " + rs2.getString("status") +
                                                "<br>Jatuh Tempo: " + rs2.getDate("tanggal_jatuh_tempo");
                            %>
                            <option value="<%= rs2.getInt("pinjaman_id") %>" data-detail="<%= detail.replace("\"", "&quot;") %>">
                                Jatuh Tempo: <%= rs2.getDate("tanggal_jatuh_tempo") %>
                            </option>
                            <% } rs2.close(); ps2.close(); conn2.close(); %>
                        </select>
                    </div>
                    <div id="pinjaman_detail" class="mb-3"></div>
                    <% } %>
                    <div class="mb-3">
                        <label for="kategori" class="form-label">Kategori Pesan</label>
                        <select class="form-select" id="kategori" name="kategori" onchange="setKategoriMsg()" required>
                            <option value="">-- Pilih Kategori --</option>
                            <option value="late">Tenggat pembayaran sudah terlambat</option>
                            <option value="approved">Status disetujui pengajuan peminjaman</option>
                            <option value="rejected">Status penolakan pengajuan peminjaman</option>
                            <option value="reminder">Pesan pengingat sebelum jatuh tempo</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="isi" class="form-label">Pesan</label>
                        <textarea class="form-control" id="isi" name="isi" rows="4" required></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary">Kirim Pesan</button>
                </form>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

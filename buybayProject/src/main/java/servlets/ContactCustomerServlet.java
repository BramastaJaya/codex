package servlets;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ContactCustomerServlet")
public class ContactCustomerServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Ambil data dari form
        String userIdParam = request.getParameter("user_id");
        String pinjamanIdParam = request.getParameter("pinjaman_id");
        String kategori = request.getParameter("kategori");
        String isi = request.getParameter("isi");

        // Validasi sederhana
        if (userIdParam == null || pinjamanIdParam == null || kategori == null || isi == null ||
            userIdParam.isEmpty() || pinjamanIdParam.isEmpty() || kategori.isEmpty() || isi.isEmpty()) {
            // Jika ada data kosong, redirect kembali ke form (bisa tambahkan pesan error)
            response.sendRedirect("contact_customer.jsp?error=1");
            return;
        }

        int userId = Integer.parseInt(userIdParam);
        int pinjamanId = Integer.parseInt(pinjamanIdParam);

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/buybay-database", "root", ""
            );
            String sql = "INSERT INTO inbox (user_id, pinjaman_id, kategori, isi) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, pinjamanId);
            ps.setString(3, kategori);
            ps.setString(4, isi);

            int inserted = ps.executeUpdate();
            ps.close();
            conn.close();

            // Sukses: redirect ke form dengan pesan sukses
            response.sendRedirect("contact_customer.jsp?success=1");
        } catch (Exception e) {
            e.printStackTrace();
            // Error: redirect ke form dengan pesan gagal
            response.sendRedirect("contact_customer.jsp?error=2");
        }
    }
}

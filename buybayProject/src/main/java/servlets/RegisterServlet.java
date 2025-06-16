package servlets;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String nama = request.getParameter("nama_lengkap");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String konfirmasiPassword = request.getParameter("konfirmasi_password");
        String noTelp = request.getParameter("no_telp");
        String alamat = request.getParameter("alamat_domisili");
        String tanggalLahir = request.getParameter("tanggal_lahir");
        String jenisKelamin = request.getParameter("jenis_kelamin");
        String ktpId = request.getParameter("ktp_id");

        // Validasi password sama
        if (!password.equals(konfirmasiPassword)) {
            response.sendRedirect("register.html?error=Password+tidak+sama");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/buybay-database", "root", ""
            );

            // Validasi email & KTP belum terdaftar
            PreparedStatement cekEmail = conn.prepareStatement("SELECT COUNT(*) FROM user WHERE email = ?");
            cekEmail.setString(1, email);
            ResultSet rsEmail = cekEmail.executeQuery();
            if (rsEmail.next() && rsEmail.getInt(1) > 0) {
                response.sendRedirect("register.html?error=Email+sudah+terdaftar");
                rsEmail.close(); cekEmail.close(); conn.close();
                return;
            }
            rsEmail.close(); cekEmail.close();

            PreparedStatement cekKtp = conn.prepareStatement("SELECT COUNT(*) FROM user WHERE ktp_id = ?");
            cekKtp.setString(1, ktpId);
            ResultSet rsKtp = cekKtp.executeQuery();
            if (rsKtp.next() && rsKtp.getInt(1) > 0) {
                response.sendRedirect("register.html?error=No+KTP+sudah+terdaftar");
                rsKtp.close(); cekKtp.close(); conn.close();
                return;
            }
            rsKtp.close(); cekKtp.close();

            // Insert ke user
            String insertUser = "INSERT INTO user (nama_lengkap, email, password, no_telp, alamat_domisili, tanggal_lahir, jenis_kelamin, ktp_id, status_user) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'customer')";
            PreparedStatement psUser = conn.prepareStatement(insertUser, Statement.RETURN_GENERATED_KEYS);
            psUser.setString(1, nama);
            psUser.setString(2, email);
            psUser.setString(3, password); // Untuk security, hash password lebih baik
            psUser.setString(4, noTelp);
            psUser.setString(5, alamat);
            psUser.setString(6, tanggalLahir);
            psUser.setString(7, jenisKelamin);
            psUser.setString(8, ktpId);

            int inserted = psUser.executeUpdate();

            // Ambil user_id
            int userId = -1;
            ResultSet generatedKeys = psUser.getGeneratedKeys();
            if (generatedKeys.next()) {
                userId = generatedKeys.getInt(1);
            }
            psUser.close();

            // Insert ke customer jika user berhasil dibuat
            if (inserted > 0 && userId != -1) {
                String insertCust = "INSERT INTO customer (user_id) VALUES (?)";
                PreparedStatement psCust = conn.prepareStatement(insertCust);
                psCust.setInt(1, userId);
                psCust.executeUpdate();
                psCust.close();
                conn.close();

                response.sendRedirect("index.html?register=success");
            } else {
                conn.close();
                response.sendRedirect("register.html?error=Gagal+registrasi");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.html?error=Gagal+registrasi+server");
        }
    }
}

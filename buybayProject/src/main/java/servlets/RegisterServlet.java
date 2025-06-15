package servlets;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/RegisterServlet"})
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String ktp = request.getParameter("ktp");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/buybay-database?useSSL=false&serverTimezone=UTC", "root", ""
            );

            String sqlUser = "INSERT INTO user (User_Name, Email, Password, status_user) VALUES (?, ?, ?, 'Customer')";
            PreparedStatement psUser = con.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS);
            psUser.setString(1, username);
            psUser.setString(2, email);
            psUser.setString(3, password);
            psUser.executeUpdate();

            ResultSet rs = psUser.getGeneratedKeys();
            int userId = 0;
            if (rs.next()) {
                userId = rs.getInt(1);
            }

            PreparedStatement psReg = con.prepareStatement("INSERT INTO registration (User_ID, User_Name, Email, Password, KTP_ID) VALUES (?, ?, ?, ?, ?)");
            psReg.setInt(1, userId);
            psReg.setString(2, username);
            psReg.setString(3, email);
            psReg.setString(4, password);
            psReg.setString(5, ktp);
            psReg.executeUpdate();

            PreparedStatement psCust = con.prepareStatement("INSERT INTO customer (User_ID, KTP_ID) VALUES (?, ?)");
            psCust.setInt(1, userId);
            psCust.setString(2, ktp);
            psCust.executeUpdate();

            response.sendRedirect("index.html");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Gagal register: " + e.getMessage());
        }
    }
}

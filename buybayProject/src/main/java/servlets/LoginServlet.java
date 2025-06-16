package servlets;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/buybay-database", "root", ""
            );

            String sql = "SELECT * FROM user WHERE email=? AND password=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()){
                int userId = rs.getInt("user_id");
                String namaLengkap = rs.getString("nama_lengkap");
                String statusUser = rs.getString("status_user");

                HttpSession session = request.getSession();
                session.setAttribute("user_id", userId);
                session.setAttribute("nama_lengkap", namaLengkap);

                if ("Admin".equalsIgnoreCase(statusUser)) {
                    session.setAttribute("nama_admin", namaLengkap);
                    session.setAttribute("role", "Admin");
                    response.sendRedirect("admin_dashboard.jsp");
                } else if ("customer".equalsIgnoreCase(statusUser)) {
                    session.setAttribute("role", "customer");
                    response.sendRedirect("customer_dashboard.jsp");
                } else {
                    response.sendRedirect("index.html?error=2");
                }
            }
            else {
                response.sendRedirect("index.html?error=1");
            }
            rs.close();
            ps.close();
            con.close();
        } catch (Exception e){
            e.printStackTrace();
            response.sendRedirect("index.html?error=1");
        }
    }
}

package servlets;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/VerifikasiPinjamanServlet")
public class VerifikasiPinjamanServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pinjamanIdParam = request.getParameter("pinjaman_id");
        String aksi = request.getParameter("aksi");
        
        if (pinjamanIdParam != null && aksi != null) {
            int pinjamanId = Integer.parseInt(pinjamanIdParam);
            String statusBaru = null;
            
            if ("accept".equals(aksi)) {
                statusBaru = "accepted";
            } else if ("reject".equals(aksi)) {
                statusBaru = "rejected";
            }

            if (statusBaru != null) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/buybay-database", "root", ""
                    );

                    String sql = "UPDATE pinjaman SET status = ? WHERE pinjaman_id = ?";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, statusBaru);
                    ps.setInt(2, pinjamanId);
                    ps.executeUpdate();
                    ps.close();
                    
                    if ("accepted".equals(statusBaru)) {
                        String updateBungaSql = "UPDATE pinjaman SET bunga = ROUND(1 + (RAND() * 4), 2) WHERE pinjaman_id = ? AND bunga IS NULL";
                        PreparedStatement bungaPs = conn.prepareStatement(updateBungaSql);
                        bungaPs.setInt(1, pinjamanId);
                        bungaPs.executeUpdate();
                        bungaPs.close();
                    }
                    
                    conn.close();

                   
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        response.sendRedirect("verifikasi.jsp");
    }
}

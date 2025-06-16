package pckg.buybayproject;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBconnection {
    private static Connection connection;

    public static Connection getConnection() {
        
        
        
        
        if (connection == null) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/buybay-database?useSSL=false&serverTimezone=UTC",
                    "root", "");
                System.out.println("Koneksi ke database berhasil.");
            } catch (ClassNotFoundException | SQLException e) {
                System.err.println("Koneksi gagal: " + e.getMessage());
            }
        }
        return connection;
    }
}

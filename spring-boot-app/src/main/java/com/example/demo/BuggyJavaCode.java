import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Scanner;

public class BuggyJavaCode {

    // Hardcoded credentials (Security Issue)
    private static final String DB_URL = "jdbc:mysql://localhost:3306/testdb";
    private static final String USER = "root";
    private static final String PASSWORD = "password123"; 

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        
        // Resource leak: Scanner not closed
        System.out.print("Enter username: ");
        String username = scanner.nextLine();

        System.out.print("Enter password: ");
        String password = scanner.nextLine();

        // SQL Injection vulnerability
        String query = "SELECT * FROM users WHERE username = '" + username + "' AND password = '" + password + "'";
        
        try {
            // Connection leak: Not closed properly
            Connection conn = DriverManager.getConnection(DB_URL, USER, PASSWORD);
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(query);

            if (rs.next()) {
                System.out.println("Login successful! Welcome, " + rs.getString("username"));
            } else {
                System.out.println("Invalid credentials.");
            }

            // Missing proper closing of resources (Connection, Statement, ResultSet)
        } catch (Exception e) {
            // Swallowing the exception (Bad practice)
            e.printStackTrace();
        }

        // Unreachable code
        System.out.println("This line will always be executed, even if an exception occurs.");
    }
}


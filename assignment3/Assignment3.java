import java.sql.*;
import java.util.List;
import java.util.ArrayList;

public class Assignment3 extends JDBCSubmission {
    private Connection conn = null;
    public Assignment3() throws ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        this.conn = null;
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        try{ 
            conn = DriverManager.getConnection(url, username, password);
        } catch(SQLException sqlE) {
            System.out.println(sqlE);
        }
        return (conn != null);
    }

    @Override
    public boolean disconnectDB() {
        try{ 
            conn.close();
        } catch(SQLException sqlE){
            System.out.println(sqlE);
            return false;
        }
        return true;
    }

    @Override
    public ElectionResult presidentSequence(String countryName) {
            //Write your code here.
            return null;
	}

    @Override
    public List<Integer> findSimilarParties(Integer partyId, Float threshold) {
	//Write your code here.
        return null;
    }

    public static void main(String[] args) throws Exception {
	    System.out.println("Hellow World");
        Assignment3 a3 = new Assignment3();
        String url = "jdbc:postgresql://localhost:5432/csc343h-elsaye10";
        String username = "elsaye10";
        a3.connectDB(url, username, "");
    }

}




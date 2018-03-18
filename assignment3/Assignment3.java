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
            //System.out.println(sqlE);
        }
        return (conn != null);
    }

    @Override
    public boolean disconnectDB() {
        try{ 
            conn.close();
        } catch(SQLException sqlE){
            //System.out.println(sqlE);
            return false;
        }
        return true;
    }

    @Override
    public ElectionResult presidentSequence(String countryName) {
        List<Integer> pids = new ArrayList<Integer>();
        List<String> parties = new ArrayList<String>();
        try {
            String query = "TODO";
            PreparedStatement execStat = conn.prepareStatement(query); 
            ResultSet entry = execStat.executeQuery();
            while (entry.next()) {
                Integer id = entry.getInt(1); 
                String party = entry.getString(2);
                parties.add(party);
                pids.add(id);
            }
        } catch (SQLException sqlE) {
            //System.out.println(sqlE);
        }
        ElectionResult r  = new ElectionResult(pids, parties);
        return r;
	}

    @Override
    public List<Integer> findSimilarParties(Integer partyId, Float threshold) {
        List<Integer> party_ids = new ArrayList<Integer>();
        try {
            String query = "SELECT p1.description, p2.id, p2.description FROM party p1 JOIN party p2 WHERE p1.id = %" + partyId + "% AND p1.id <> p2.id AND p1.id";
            PreparedStatement execStat = conn.prepareStatement(query); 
            ResultSet entry = execStat.executeQuery();
            while (entry.next()) {
                String p1_description = entry.getString(1); 
                Integer pid2 = entry.getInt(2); 
                String p2_description = entry.getString(3); 
                if(similarity(p1_description, p2_description) > threshold) {
                    party_ids.add(pid2);
                }
            }
        } catch (SQLException sqlE) {
            //System.out.println(sqlE);
        }
        return party_ids;
    }

    public static void main(String[] args) throws Exception {
	    //System.out.println("Hellow World");
        //Assignment3 a3 = new Assignment3();
        //String url = "jdbc:postgresql://localhost:5432/csc343h-elsaye10";
        //String username = "elsaye10";
        //boolean success = a3.connectDB(url, username, "");
        ////System.out.println("success? " + success);
        //a3.presidentSequence("France");
        //success = a3.disconnectDB();
        ////System.out.println("success? " + success);
    }

}




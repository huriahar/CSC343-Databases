import java.sql.*;
import java.util.List;
import java.util.ArrayList;

public class Assignment3 extends JDBCSubmission {
    public Assignment3() throws ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        this.connection = null;
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        try{ 
            connection = DriverManager.getConnection(url, username, password);
        } catch(SQLException sqlE) {
            return false;
        }
        return (connection != null);
    }

    @Override
    public boolean disconnectDB() {
        try{ 
            connection.close();
        } catch(SQLException sqlE){
            return false;
        }
        return true;
    }

    @Override
    public ElectionResult presidentSequence(String countryName) {
        List<Integer> pids = new ArrayList<Integer>();
        List<String> parties = new ArrayList<String>();
        try {
            // Find all presidents and the parties they are from in the given country
            String query = "SELECT politician_president.id, party.name FROM politician_president JOIN party ON party.id = politician_president.party_id JOIN country ON politician_president.country_id = country.id WHERE country.name = '" + countryName + "' ORDER BY end_date;";
            PreparedStatement execStat = connection.prepareStatement(query); 
            ResultSet entry = execStat.executeQuery();
            //For every entry returned, get the president id and party name
            while (entry.next()) {
                Integer id = entry.getInt(1); 
                String party = entry.getString(2);
                parties.add(party);
                pids.add(id);
            }
        } catch (SQLException sqlE) {

        }
        ElectionResult r  = new ElectionResult(pids, parties);
        return r;
    }

    @Override
    public List<Integer> findSimilarParties(Integer partyId, Float threshold) {
        List<Integer> party_ids = new ArrayList<Integer>();
        try {
            // Find all parties whose description has a jaccard_score >= threshold (compared to the given party's description)
            String query = "SELECT p1.description, p2.id, p2.description FROM party p1 JOIN party p2 ON p1.id <> p2.id WHERE p1.id = " + partyId + ";";
            PreparedStatement execStat = connection.prepareStatement(query); 
            ResultSet entry = execStat.executeQuery();
            while (entry.next()) {
                String p1_description = entry.getString(1); 
                Integer pid2 = entry.getInt(2); 
                String p2_description = entry.getString(3); 
                Float jaccard_score;
                //if one of the parties' descriptions is null, the similarity score should be 0.0
                if (p1_description == null || p2_description == null) {
                    jaccard_score = (float)0.0;
                } else {
                    jaccard_score = (float)similarity(p1_description, p2_description);
                }
                if(jaccard_score >= threshold) {
                    party_ids.add(pid2);
                }
            }
        } catch (SQLException sqlE) {

        }
        return party_ids;
    }

    public static void main(String[] args) throws Exception {

    }

}




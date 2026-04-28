package pharmacy;

public class Doctor {
	private String fName;
	private String lName;
	private String am;
	private Prescription[] listOfPrescriptions;
	private int numOfPrescriptions;
	
	public Doctor(String fn, String ln, String c) {
		fName = fn;
		lName = ln;
		am = c;
		numOfPrescriptions = 0;
		listOfPrescriptions = new Prescription[50];
	}
	
	public String getfName() {
		return fName;
	}
	public String getlName() {
		return lName;
	}
	public String getAM() {
		return am;
	}
	
	public void addPrescription(Prescription p) {
		listOfPrescriptions[numOfPrescriptions] = p;
		numOfPrescriptions++;
	}
	
	public void removePrescription(String code) {
		int count = 0;
		for(Prescription p : listOfPrescriptions) {
			if(p != null && p.getCode().equals(code)) {
				listOfPrescriptions[count] = null;
				numOfPrescriptions--;
			}
			count++;
		}
	}
}

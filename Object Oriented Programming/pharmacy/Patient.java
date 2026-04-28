package pharmacy;

public class Patient {
	private String fName;
	private String lName;
	private int amka;
	private Prescription[] listOfPrescriptions;
	private int numOfPrescriptions;
	
	public Patient() {
		
	}
	public Patient(String fn, String ln, int amka) {
		fName = fn;
		lName = ln;
		this.amka = amka;
		numOfPrescriptions = 0;
		listOfPrescriptions = new Prescription[50];
	}
	
	public String getfName() {
		return fName;
	}
	public String getlName() {
		return lName;
	}
	public int getAmka() {
		return amka;
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

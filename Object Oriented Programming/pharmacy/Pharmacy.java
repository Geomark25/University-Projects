package pharmacy;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import utility.MyScanner;

public class Pharmacy {
	//Pharmacy's details
	@SuppressWarnings("unused")
	private String name;
	@SuppressWarnings("unused")
	private String address;
	@SuppressWarnings("unused")
	private long phone;
	//Pharmacy's patients
	private Patient[] listOfPatients;
	private int numOfPatients;
	//Pharmacy's doctors
	private Doctor[] listOfDoctors;
	private int numOfDoctors;
	//Pharmacy's medicines
	private Medicine[] listOfMedicines;
	private int numOfMedicines;
	//Pharmacy's prescriptions
	private Prescription[] listOfPrescriptions;
	private int numOfPrescriptions;
	
	public Pharmacy(String n, String a, long p) {
		listOfDoctors = new Doctor[50];
		listOfPatients = new Patient[50];
		listOfMedicines = new Medicine[50];
		listOfPrescriptions = new Prescription[50];
		numOfPrescriptions = 0;
		numOfMedicines = 0;
		numOfPatients = 0;
		numOfDoctors = 0;
		name = n;
		address = a;
		phone = p;
	}
	
	DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy");
	MyScanner in = new MyScanner();
	
	//Get number of Prescriptions
	public int getNumOfPrescriptions() {
		return numOfPrescriptions;
	}
	//Get number of Medicines
	public int getNumOfMedicines() {
		return numOfMedicines;
	}
	//Get number of Patients
	public int getNumOfPatients() {
		return numOfPatients;
	}
	//Get number of Doctors
	public int getNumOfDoctors() {
		return numOfDoctors;
	}
	
	//Update doctor list
	public void addNewDoctor(Doctor d) {
		listOfDoctors[numOfDoctors] = d;
		numOfDoctors++;
	}
	//Update patient list
	public void addNewPatient(Patient p) {
		listOfPatients[numOfPatients] = p;
		numOfPatients++;
	}
	//Update medicine list
	public void addNewMedicine(Medicine m) {
		listOfMedicines[numOfMedicines] = m;
		numOfMedicines++;
	}
	//Update prescription list
	public void addNewPrescription(Prescription p) {
		p.getDoc().addPrescription(p);
		p.getPatient().addPrescription(p);
		listOfPrescriptions[numOfPrescriptions] = p;
		numOfPrescriptions++;
	}

	//Print all medicine
	public int printAllMedicine() {
		int counter = 0;
		if(numOfMedicines > 0) {
			System.out.println("\nMedicine:");
			for(Medicine m : listOfMedicines) {
				if(m != null) {
					counter++;
					System.out.println(counter + ". " + m.getName()+" with code: "+m.getCode()+" at "+m.getPrice()+"€");
				}
				
			}
			if(counter == 0) {
				System.err.println("There has been an error during medicine print.");
			}
		}
		else {
			System.out.println("There are no medicine in stock.");
		}
		System.out.println();
		return counter;
	}
	
	//Print all doctors
	public int printAllDoctors() {
		int counter = 0;
		if(numOfDoctors > 0) {
			System.out.println("\nDoctors:");
			for(Doctor d : listOfDoctors) {
				if(d != null) {
					counter++;
					System.out.println(counter + ". " + d.getfName()+ " "+d.getlName()+" with AM: "+d.getAM());
				}
			}
			if(counter == 0) {
				System.err.println("There has been an error during doctor print.");
			}
		}
		else {
			System.out.println("There are no doctors listed.\n");
		}
		System.out.println();
		return counter;
	}
	
	//Print all patients
	public int printAllPatients() {
		int counter = 0;
		if(numOfPatients > 0) {
			System.out.println("\nPatients:");
			for(Patient p : listOfPatients) {
				if(p != null) {
					counter++;
					System.out.println(counter + ". " + p.getfName()+" "+p.getlName()+" with AMKA: "+p.getAmka());
				}
				
			}
			if(counter == 0) {
				System.err.println("There has been an error during patient print.");
			}
		}
		else {
			System.out.println("There are no patients listed.\n");
		}
		System.out.println();
		return counter;
	}
	
	//Print all prescriptions
	public int printAllPrescriptions() {
		int counter = 0;
		if(numOfPrescriptions > 0) {
			System.out.println("\nPrescriptions:");
			for(Prescription p : listOfPrescriptions) {
				if(p != null) {
					counter++;
					System.out.println(counter + ". " + p.getCode()+" with prescripbed medicines:");
					PrescripbedMeds[] meds = p.getMeds();
					for(int i = 0; i < 6; i++) {
						if(meds[i] != null) {
							System.out.println("\t"+meds[i].getMed().getName()+" of quantity "+meds[i].getAmount());
						}
					}
				}
				
			}
			if(counter == 0) {
				System.err.println("There has been an error during prescription print.");
			}
		}
		else {
			System.out.println("There are no prescriptions listed.\n");
		}
		System.out.println();
		return counter;
	}
	
	//Find Medicine By Name
	public Medicine findMedicineByName(String str) {
		for(Medicine m : listOfMedicines) {
			if(m != null && m.getName().equals(str)) {
				return m;
			}
		}
		str = in.readString("Medicine " + str + " does not exist.\n");
		return null;
	}
	
	//Find Medicine By Code
	public Medicine findMedicineByCode(String str) {
		for(Medicine m: listOfMedicines) {
			if(m != null && m.getCode().equals(str)) {
				return m;
			}
		}
		return null;
	}
	
	//Find Doctor By Name
	public Doctor findDoctorByName() {
		int assist = printAllDoctors();
		if(assist != 0) {
			String str = in.readString("Enter doctor's full name(<first name> <last name>):");
			String[] name = str.split(" ");
			for(Doctor d : listOfDoctors) {
				 if(d != null && d.getfName().equals(name[0]) && d.getlName().equals(name[1])) {
					 return d;
				}
			}
			str = in.readString("Doctor " + str + " does not exist.\n");
		}
		return null;	
	}
	
	//Find Doctor By AM
	public Doctor findDoctorByAM(String am) {
		for(Doctor d : listOfDoctors) {
			if(d != null && d.getAM().equals(am)) {
				return d;
			}
		}
		System.out.println("There are no doctors with AM "+am+".\n");
		return null;
	}
	
	//Find Patient By AMKA
	public Patient findPatientByAMKA(int amka) {
		for(Patient p : listOfPatients) {
			if(p != null && p.getAmka() == amka) {
				return p;
			}
		}
		System.out.println("There are no patients with AMKA "+amka+".\n");
		return null;
	}
	
	//Find Patient By Name
	public Patient findPatientByName() {
		int assist = printAllPatients();
		if(assist != 0) {
		    String str = in.readString("Enter patient's full name(<first name> <last name>):");
			String[] name = str.split(" ");
			for(Patient p : listOfPatients) {
				if(p != null && p.getfName().equals(name[0]) && p.getlName().equals(name[1])) {
					return p;
				}
			}
			str = in.readString("Patient " + str + " does not exist.\nTry again or press Enter to stop:");
		}
		return null;
	}
	
	//Get Medicine and amount for new prescription
	public PrescripbedMeds[] getMedsAndAmount() {
		String str = null;
		String[] nameAmount = null;
		PrescripbedMeds[] meds = new PrescripbedMeds[6];
		int assist = printAllMedicine();
		if(assist != 0) {
			System.out.println("Choose the medicines you want to prescripe, up to 6:");
			for(int i = 0; i < assist; i++) {
				str = in.readString("Enter medicine name and amount or press Enter to stop(<name> <amount>):");
				if(str.isEmpty()) {
					break;
				}
				else {
					nameAmount = str.split(" ");
					meds[i] = new PrescripbedMeds(findMedicineByName(nameAmount[0]), Integer.parseInt(nameAmount[1]));
				}
			}
			return meds;
		}
		return null;
	}
	
	//Delete prescription by code
	public boolean deletePrescription(String code) {
		int count = 0;
		for(Prescription p : listOfPrescriptions) {
			if(p != null && p.getCode().equals(code)) {
				listOfPrescriptions[count] = null;
				numOfPrescriptions--;
				p.getDoc().removePrescription(code);
				p.getPatient().removePrescription(code);
				return true;
			}
			count++;
		}
		System.out.println("Prescription "+code+" does not exist.\n");
		return false;
	}
	
	//Print prescription by code
	public void printPrescription(String code) {
		boolean assist = false;
		for(Prescription p : listOfPrescriptions) {
			if(p != null && p.getCode().equals(code)) {
				assist = true;
				System.out.println("Prescription by "+p.getDocName()+" for patient "+p.getPatientName()+":");
				System.out.println("\tPrescripbed medicines:");
				PrescripbedMeds[] meds = p.getPrescripbedMeds();
				for(int i = 0; i < 6; i++) {
					if(meds[i] != null) {
						System.out.println("\t\t"+p.getQuantity(i)+" "+p.getMedName(i)+" with code "+p.getMedCode(i));
					}
				}
			}
			
		}
		if(!assist) {
			System.out.println("There are no matching prescriptions with code "+code+".\n");
		}
	}
	
	//Print prescription by doctor's AM
	public void printPrescription(Doctor d) {
		boolean assist = false;
		for(Prescription p : listOfPrescriptions) {
			if(p != null && p.getDocAM().equals(d.getAM())) {
				assist = true;
				System.out.println("Prescription by "+p.getDocName()+" for patient "+p.getPatientName()+":");
				System.out.println("\tPrescripbed medicines:");
				PrescripbedMeds[] meds = p.getPrescripbedMeds();
				for(int i = 0; i < 6; i++) {
					if(meds[i] != null) {
						System.out.println("\t\t"+p.getQuantity(i)+" "+p.getMedName(i)+" with code "+p.getMedCode(i));
					}
				}
			}
			
		}
		if(!assist) {
			System.out.println("There are no matching prescriptions with doctor's am "+d.getAM()+".\n");
		}
	}
	
	//Print prescription by patient's AMKA
	public void printPrescription(Patient patient) {
		boolean assist = false;
		for(Prescription p : listOfPrescriptions) {
			if(p != null && p.getPatientAMKA() == patient.getAmka()) {
				assist = true;
				System.out.println("Prescription by "+p.getDocName()+" for patient "+p.getPatientName()+":");
				System.out.println("\tPrescripbed medicines:");
				PrescripbedMeds[] meds = p.getPrescripbedMeds();
				for(int i = 0; i < 6; i++) {
					if(meds[i] != null) {
						System.out.println("\t\t"+p.getQuantity(i)+" "+p.getMedName(i)+" with code "+p.getMedCode(i));
					}
				}
			}
			
		}
		if(!assist) {
			System.out.println("There are no matching prescriptions with patients's AMKA "+patient.getAmka()+".\n");
		}
	}
	
	//Print prescription by specified date period
	public void printPrescriptionByDate(LocalDate s, LocalDate f) {
		boolean assist = false;
		for(Prescription p : listOfPrescriptions) {
			if(p != null && (p.getDate().isEqual(f) || p.getDate().isBefore(f)) && (p.getDate().isEqual(s) || p.getDate().isAfter(s))) {
				assist = true;
				System.out.println("Prescription by "+p.getDocName()+" for patient "+p.getPatientName()+":");
				System.out.println("\tPrescripbed medicines:");
				PrescripbedMeds[] meds = p.getPrescripbedMeds();
				for(int i = 0; i < 6; i++) {
					if(meds[i] != null) {
						System.out.println("\t\t"+p.getQuantity(i)+" "+p.getMedName(i)+" with code "+p.getMedCode(i));
					}
				}
			}
			
		}
		if(!assist) {
			System.out.println("There are no matching prescriptions on specified date period.\n");
		}
	}
	
	//Calculate prescription price by doctor
	public float calculatePrice(Doctor d) {
		float price = 0;
		float pricePerQuantity = 0;
		for(Prescription p : listOfPrescriptions) {
			if(p != null && p.getDocAM() == d.getAM()) {
				PrescripbedMeds[] meds = p.getMeds();
				for(int i = 0; i < 6; i++) {
					if(meds[i] != null) {
						pricePerQuantity = meds[i].getAmount() * meds[i].getMed().getPrice();
						price += pricePerQuantity;
					}
				}
			}
		}
		return price;
	}
	
	//Calculate prescription price by patient
	public float calculatePrice(Patient p) {
		float price = 0;
		float pricePerQuantity = 0;
		for(Prescription prescription : listOfPrescriptions) {
			if(prescription != null && prescription.getPatientAMKA() == p.getAmka()) {
				PrescripbedMeds[] meds = prescription.getMeds();
				for(int i = 0; i < 6; i++) {
					if(meds[i] != null) {
						pricePerQuantity = meds[i].getAmount() * meds[i].getMed().getPrice();
						price += pricePerQuantity;
					}
				}
			}
		}
		return price;
	}
}

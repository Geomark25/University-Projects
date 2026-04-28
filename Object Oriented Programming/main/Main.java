package main;

import utility.MyScanner;
import pharmacy.Doctor;
import pharmacy.Medicine;
import pharmacy.Patient;
import pharmacy.Pharmacy;
import pharmacy.Prescription;
import pharmacy.PrescripbedMeds;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class Main {

	public static void main(String[] args) {
		Pharmacy shop = new Pharmacy("Good Pharmacy", "1 Agora, Chania", 2821012345L);
		MyScanner in = new MyScanner();
		DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy");
		
		//Create 5 doctors at the start of the program
		shop.addNewDoctor(new Doctor("doctor1_nm", "doctor1_sn", "doc11111"));
		shop.addNewDoctor(new Doctor("doctor2_nm", "doctor2_sn", "doc22222"));
		shop.addNewDoctor(new Doctor("doctor3_nm", "doctor3_sn", "doc33333"));
		shop.addNewDoctor(new Doctor("doctor4_nm", "doctor4_sn", "doc44444"));
		shop.addNewDoctor(new Doctor("doctor5_nm", "doctor5_sn", "doc55555"));
		
		//Create 5 patients at the start of the program
		shop.addNewPatient(new Patient("patient1_nm", "patient1_sn", 11111111));
		shop.addNewPatient(new Patient("patient2_nm", "patient2_sn", 22222222));
		shop.addNewPatient(new Patient("patient1_nm", "patient1_sn", 33333333));
		shop.addNewPatient(new Patient("patient1_nm", "patient1_sn", 44444444));
		shop.addNewPatient(new Patient("patient1_nm", "patient1_sn", 55555555));
		
		//Create 5 medicine at the start of the program
		shop.addNewMedicine(new Medicine("med1_nm", "med11111", 10));
		shop.addNewMedicine(new Medicine("med2_nm", "med22222", 20));
		shop.addNewMedicine(new Medicine("med3_nm", "med33333", 30));
		shop.addNewMedicine(new Medicine("med4_nm", "med44444", 40));
		shop.addNewMedicine(new Medicine("med5_nm", "med55555", 50));
		
		//Create 9 prescriptions at the start of the program
		PrescripbedMeds[] p = new PrescripbedMeds[6];
		p[1] = new PrescripbedMeds(shop.findMedicineByCode("med11111"), 2);
		p[2] = new PrescripbedMeds(shop.findMedicineByCode("med22222"), 4);
		p[3] = new PrescripbedMeds(shop.findMedicineByCode("med33333"), 1);
		shop.addNewPrescription(new Prescription(shop.findDoctorByAM("doc11111"), shop.findPatientByAMKA(11111111), "prescr11111", LocalDate.parse(("23/03/2022"), dtf), p));
		p = null; p = new PrescripbedMeds[6];
		p[1] = new PrescripbedMeds(shop.findMedicineByCode("med11111"), 1);
		shop.addNewPrescription(new Prescription(shop.findDoctorByAM("doc11111"), shop.findPatientByAMKA(22222222), "prescr22222", LocalDate.parse(("24/03/2022"), dtf), p));
		p = null; p = new PrescripbedMeds[6];
		p[1] = new PrescripbedMeds(shop.findMedicineByCode("med11111"), 3);
		p[2] = new PrescripbedMeds(shop.findMedicineByCode("med33333"), 2);
		shop.addNewPrescription(new Prescription(shop.findDoctorByAM("doc22222"), shop.findPatientByAMKA(22222222), "prescr33333", LocalDate.parse(("25/03/2022"), dtf), p));
		p = null; p = new PrescripbedMeds[6];
		p[1] = new PrescripbedMeds(shop.findMedicineByCode("med44444"), 1);
		p[2] = new PrescripbedMeds(shop.findMedicineByCode("med33333"), 2);
		p[3] = new PrescripbedMeds(shop.findMedicineByCode("med11111"), 1);
		shop.addNewPrescription(new Prescription(shop.findDoctorByAM("doc22222"), shop.findPatientByAMKA(33333333), "prescr44444", LocalDate.parse(("26/03/2022"), dtf), p));
		p = null; p = new PrescripbedMeds[6];
		p[1] = new PrescripbedMeds(shop.findMedicineByCode("med11111"), 1);
		p[2] = new PrescripbedMeds(shop.findMedicineByCode("med55555"), 1);
		p[3] = new PrescripbedMeds(shop.findMedicineByCode("med22222"), 1);
		shop.addNewPrescription(new Prescription(shop.findDoctorByAM("doc33333"), shop.findPatientByAMKA(33333333), "prescr55555", LocalDate.parse(("01/04/2022"), dtf), p));
		p = null; p = new PrescripbedMeds[6];
		p[1] = new PrescripbedMeds(shop.findMedicineByCode("med44444"), 2);
		p[2] = new PrescripbedMeds(shop.findMedicineByCode("med55555"), 2);
		shop.addNewPrescription(new Prescription(shop.findDoctorByAM("doc33333"), shop.findPatientByAMKA(11111111), "prescr66666", LocalDate.parse(("04/04/2022"), dtf), p));
		p = null; p = new PrescripbedMeds[6];
		p[1] = new PrescripbedMeds(shop.findMedicineByCode("med44444"), 1);
		p[2] = new PrescripbedMeds(shop.findMedicineByCode("med11111"), 2);
		shop.addNewPrescription(new Prescription(shop.findDoctorByAM("doc44444"), shop.findPatientByAMKA(44444444), "prescr77777", LocalDate.parse(("06/04/2022"), dtf), p));
		p = null; p = new PrescripbedMeds[6];
		p[1] = new PrescripbedMeds(shop.findMedicineByCode("med22222"), 5);
		shop.addNewPrescription(new Prescription(shop.findDoctorByAM("doc44444"), shop.findPatientByAMKA(55555555), "prescr88888", LocalDate.parse(("16/04/2022"), dtf), p));
		p = null; p = new PrescripbedMeds[6];
		p[1] = new PrescripbedMeds(shop.findMedicineByCode("med55555"), 5);
		shop.addNewPrescription(new Prescription(shop.findDoctorByAM("doc55555"), shop.findPatientByAMKA(55555555), "prescr99999", LocalDate.parse(("20/04/2022"), dtf), p));
		p = null;
		
		int userOption = 0;
		int choice = 0;
		while(userOption != 9) {
			userOption = 0;
			printMenu();
			userOption = in.readInt("Please, choose what you would like to do:");
			switch (userOption) {
			case 1:
				if(shop.getNumOfMedicines() < 50) {
					shop.addNewMedicine(new Medicine(in.readString("Write medicine's name:"), in.readString("Now, enter medicine's code:"), in.readFloat("Finally, enter medicine's price:")));
					System.out.println("Done!\n");
				}
				else {
					System.out.println("There is no space available to add more medicines.");
				}
				in.readString("Press any key to continue...");
				break;
			case 2:
				if(shop.getNumOfDoctors() < 50) {
					shop.addNewDoctor(new Doctor(in.readString("Write the doctor's first name:"), in.readString("Write doctor's last name"), in.readString("Now, enter doctor's AM:")));
					System.out.println("Done!\n");
				}
				else {
					System.out.println("There is no space available to add more doctors.");
				}
				in.readString("Press any key to continue...");
				break;
			case 3:
				if(shop.getNumOfPatients() < 50) {
					shop.addNewPatient(new Patient(in.readString("Write the patient's first name:"), in.readString("Write the patient's last name"), in.readInt("Now, enter patient's amka:")));
					System.out.println("Done!\n");
				}
				else {
					System.out.println("There is no space available to add more patients.");
				}
				in.readString("Press any key to continue...");
				break;
			case 4:
				if(shop.getNumOfPrescriptions() < 50) {
					shop.addNewPrescription(new Prescription(shop.findDoctorByName(), shop.findPatientByName(), in.readString("Now, enter prescription's code:"), 
															 LocalDate.parse(in.readString("Finally, enter prescripiton date(dd/MM/yyyy):"), dtf), shop.getMedsAndAmount()));
					System.out.println("Done!\n");
				}
				else {
					System.out.println("There is no space available to add more prescriptions.");
				}
				in.readString("Press any key to continue...");
				break;
			case 5:
				if(shop.printAllPrescriptions() != 0) {
					boolean s = shop.deletePrescription(in.readString("Enter the prescription code you want to delete:"));
					if(s) {
						System.out.println("Done!\n");
					}
				}
				in.readString("Press any key to continue...");
				break;
			case 6:
				choice = 0;
				while(choice < 1 || choice > 5) {
					printFindMenu();
					choice = in.readInt("Please, choose what you would like to do:");
					switch(choice) {
					case 1:
						shop.printPrescription(in.readString("Enter prescription code you would like to find:"));
						in.readString("Press any key to continue...");
						break;
					case 2:
						shop.printPrescription(shop.findDoctorByAM(in.readString("Enter doctor's AM:")));
						in.readString("Press any key to continue...");
						break;
					case 3:
						shop.printPrescription(shop.findPatientByAMKA(in.readInt("Enter patient's AMKA:")));
						in.readString("Press any key to continue...");
						break;
					case 4:
						shop.printPrescriptionByDate(LocalDate.parse(in.readString("Enter starting period in 'dd/MM/yyyy':"), dtf), 
													 LocalDate.parse(in.readString("Enter ending period in 'dd/MM/yyyy':"), dtf));
						in.readString("Press any key to continue...");
						break;
					case 5:
						break;
					default:
						System.out.println("Invalid choice. Try again.\n");
						break;
					}
				}
				break;
			case 7:
				choice = 0;
				while(choice < 1 || choice > 3) {
					printPriceMenu();
					choice = in.readInt("Please, choose what you would like to do:");
					switch(choice) {
						case 1:
							System.out.println("Price calculated to be: "+ shop.calculatePrice(shop.findDoctorByAM(in.readString("Enter doctor's AM to calculate price of prescriptions:")))+" €");
							in.readString("Press any key to continue...");
							break;
						case 2:
							System.out.println("Price calculated to be: "+ shop.calculatePrice(shop.findPatientByAMKA(in.readInt("Enter patient's AMKA to calculate price of prescription:")))+" €");
							in.readString("Press any key to continue...");
							break;
						case 3:
							break;
						default:
							System.out.println("Invalid choice. Try again.\n");
							break;
					}
				}
				break;
			case 8:
				choice = 0;
				while(choice < 1 || choice > 5) {
					printPrintingMenu();
					choice = in.readInt("Please, choose what you would like to do:");
					switch(choice) {
					case 1:
						shop.printAllDoctors();
						in.readString("Press any key to continue...");
						break;
					case 2:
						shop.printAllPatients();
						in.readString("Press any key to continue...");
						break;
					case 3:
						shop.printAllMedicine();
						in.readString("Press any key to continue...");
						break;
					case 4:
						shop.printAllPrescriptions();
						in.readString("Press any key to continue...");
						break;
					case 5:
						break;
					default:
						System.out.println("Invalild choice. Try again.\n");
						break;
					}
				}
				break;
			case 9:
				System.out.println("Thank you for using the program.");
				in.readString("Press any key to continue...");
				break;
			default:
				System.out.println("Invalid choice. Please try again.\n");
				break;
			}
		}
		in.close();
	}
	
	public static void printMenu() {
		System.out.println("       Pharmacy console");
		System.out.println("================================");
		System.out.println("1. Create New Medicine..........");
		System.out.println("2. Create New Doctor............");
		System.out.println("3. Create New Patient...........");
		System.out.println("4. Create a New Prescription....");
		System.out.println("5. Delete a Prescription........");
		System.out.println("6. Find Prescription............");
		System.out.println("7. Calculate Prescription Cost..");
		System.out.println("8. Print all....................");
		System.out.println("9. Exit Program.................");
		System.out.println("================================");
	}
	
	public static void printFindMenu() {
		System.out.println("Find prescription by:");
		System.out.println("\t1. Code");
		System.out.println("\t2. Doctor's AM");
		System.out.println("\t3. Patient's AMKA");
		System.out.println("\t4. Specific period date");
		System.out.println("\t5. Return to menu");
	}
	
	public static void printPriceMenu() {
		System.out.println("Calculate price by:");
		System.out.println("\t1. Doctor's AM");
		System.out.println("\t2. Patient's AMKA");
		System.out.println("\t3. Return to menu");
	}
	
	public static void printPrintingMenu() {
		System.out.println("Print all:");
		System.out.println("\t1. Doctors");
		System.out.println("\t2. Patients");
		System.out.println("\t3. Medicines");
		System.out.println("\t4. Prescriptions");
		System.out.println("\t5. Return to menu");
	}
}

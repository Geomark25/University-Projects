package pharmacy;

import java.time.LocalDate;

public class Prescription {
	private String code;
	private Doctor doc;
	private Patient patient;
	private LocalDate prescriptionDate;
	private PrescripbedMeds[] meds;
	
	public Prescription(Doctor doc, Patient patient, String c, LocalDate prescriptionDate, PrescripbedMeds[] p) {
		this.doc = doc;
		this.patient = patient;
		code = c;
		this.prescriptionDate = prescriptionDate;
		meds = p;
	}

	public String getCode() {
		return code;
	}
	public String getDocName() {
		return doc.getfName();
	}
	public String getDocAM() {
		return doc.getAM();
	}
	public Doctor getDoc() {
		return doc;
	}
	public String getPatientName() {
		return patient.getfName();
	}
	public long getPatientAMKA() {
		return patient.getAmka();
	}
	public Patient getPatient() {
		return patient;
	}
	public PrescripbedMeds[] getPrescripbedMeds() {
		return meds;
	}
	public String getMedName(int i) {
		return meds[i].getMed().getName();
	}
	public String getMedCode(int i) {
		return meds[i].getMed().getCode();
	}
	public LocalDate getDate() {
		return prescriptionDate;
	}
	public PrescripbedMeds[] getMeds() {
		return meds;
	}
	public int getQuantity(int i) {
		return meds[i].getAmount();
	}
}

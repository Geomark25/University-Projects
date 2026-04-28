package pharmacy;


//THIS CLASS IS USED TO GET A MEDICINE AND THE AMOUNT
public class PrescripbedMeds {
	private Medicine med;
	private int amount;
	
	public PrescripbedMeds(Medicine med, int amount) {
		this.med = med;
		this.amount = amount;
	}
	
	
	public Medicine getMed() {
		return med;
	}
	public int getAmount() {
		return amount;
	}
}

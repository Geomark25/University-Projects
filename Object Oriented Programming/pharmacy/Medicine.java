package pharmacy;

public class Medicine {
	private String code;
	private String name;
	private float price;
	
	
	public Medicine(String n, String c, float p) {
		code = c;
		name = n;
		price = p;
	}

	public String getCode() {
		return code;
	}
	public String getName() {
		return name;
	}
	public float getPrice() {
		return price;
	}
}
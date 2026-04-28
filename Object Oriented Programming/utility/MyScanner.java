package utility;

import java.util.Scanner;

public class MyScanner {
	private Scanner in;
	
	public MyScanner() {
		in = new Scanner(System.in);
	}
	
	public String readString(String assist) {
		System.out.println(assist);
		return in.nextLine();
	}
	
	public int readInt(String assist) {
		System.out.println(assist);
		return Integer.parseInt(in.nextLine());
	}
	
	public float readFloat(String assist) {
		System.out.println(assist);
		return Float.parseFloat(in.nextLine());
	}
	
	public void close() {
		in.close();
	}
}

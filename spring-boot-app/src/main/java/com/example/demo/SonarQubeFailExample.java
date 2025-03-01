package com.example.demo;

/**
 * This class demonstrates code that passes Checkstyle
 * but fails SonarQube due to bad practices.
 */
public class SonarQubeFailExample {

    /**
     * Main method to demonstrate bad practices that SonarQube will flag.
     * @param args Command-line arguments
     */
    public static void main(String[] args) {
        System.out.println("Starting process...");

        int result = complexCalculation(5);
        System.out.println("Result: " + result);

        System.exit(0); // ❌ SonarQube does not recommend using System.exit()
    }

    /**
     * A method with high Cyclomatic Complexity (too many conditions and loops).
     * SonarQube will detect it as problematic.
     * @param n An integer input.
     * @return Computed result.
     */
    public static int complexCalculation(int n) {
        int sum = 0;
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                if (i % 2 == 0) {
                    sum += i * j;
                } else {
                    sum -= i + j;
                }
            }
        }
        return sum;
    }

    /**
     * Duplicate method that SonarQube will detect as a code duplication issue.
     * @param n An integer input.
     * @return Computed result.
     */
    public static int duplicateMethod(int n) {
        int sum = 0;
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                if (i % 2 == 0) {
                    sum += i * j;
                } else {
                    sum -= i + j;
                }
            }
        }
        return sum;
    }
}


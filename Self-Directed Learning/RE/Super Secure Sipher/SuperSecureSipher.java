/* Decompiler 21ms, total 1045ms, lines 95 */
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.OpenOption;
import java.nio.file.Paths;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SecureRandom;
import java.util.Scanner;

public class SuperSecureSipher {
   public static final int IV_ITERATIONS = 256;

   public static void main(String[] var0) {
      if (var0.length == 0) {
         System.out.println("Usage: SecureEncoder <input filepath>");
         System.exit(0);
      }

      String var1 = readFirstLine(var0[0]);
      writeToFile(encrypt(var1), var0[0] + ".out");
   }

   public static void writeToFile(String var0, String var1) {
      try {
         byte[] var2 = var0.getBytes();
         Files.write(Paths.get(var1), var2, new OpenOption[0]);
      } catch (IOException var3) {
         System.out.println("Failed to write to output file.");
      }

   }

   public static String readFirstLine(String var0) {
      String var1 = "";

      try {
         File var2 = new File(var0);
         Scanner var3 = new Scanner(var2);
         if (var3.hasNextLine()) {
            var1 = var3.nextLine();
         }

         var3.close();
         return var1;
      } catch (IOException var4) {
         System.out.println("Failed to read input file.");
         return var1;
      }
   }

   public static String encrypt(String var0) {
      String var1 = "";
      SecureRandom var2 = getSecureRandomGenerator();
      if (var2 == null) {
         System.exit(0);
      }

      int var3 = 0;

      int var4;
      for(var4 = 0; var4 < 256; ++var4) {
         var3 ^= var2.nextInt(256);
      }

      var4 = var3;
      int var5 = 0;

      int var6;
      for(var6 = var0.length(); var5 < var6; ++var5) {
         var4 ^= var0.charAt(var5);
      }

      var1 = var1 + (char)var4;
      var5 = 0;
      var6 = 0;

      for(int var7 = var0.length() - 1; var6 < var7; ++var6) {
         var5 ^= var0.charAt(var6);
         var1 = var1 + (char)(var4 ^ var5);
      }

      return var1;
   }

   public static SecureRandom getSecureRandomGenerator() {
      try {
         return SecureRandom.getInstance("SHA1PRNG", "SUN");
      } catch (NoSuchProviderException | NoSuchAlgorithmException var1) {
         System.out.println("Failed to init Secure RNG");
         return null;
      }
   }
}

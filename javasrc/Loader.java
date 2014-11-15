package com.supermomonga.rukkit;

import java.util.stream.Stream;
import java.util.stream.Collectors;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.BufferedReader;

public class Loader {

  public String getResourceAsString(String path) {
    String scriptBuffer = "";
    InputStream is = null;
    BufferedReader br = null;
    try {
      is = this.getClass().getClassLoader().getResource(path).openStream();
      br = new BufferedReader(new InputStreamReader(is));
      scriptBuffer =
        br.lines().collect(Collectors.joining("\n"));
    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      if (is != null) try { is.close(); } catch (IOException e) {}
      if (br != null) try { br.close(); } catch (IOException e) {}
    }
    return scriptBuffer;
  }

}

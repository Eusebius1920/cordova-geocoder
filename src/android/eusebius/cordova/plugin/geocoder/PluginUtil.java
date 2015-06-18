package eusebius.cordova.plugin.geocoder;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.LatLngBounds.Builder;

public class PluginUtil {

  public static List<LatLng> JSONArray2LatLngList(JSONArray points) throws JSONException  {
    List<LatLng> path = new ArrayList<LatLng>();
    JSONObject pointJSON;
    int i = 0;
    for (i = 0; i < points.length(); i++) {
      pointJSON = points.getJSONObject(i);
      path.add(new LatLng(pointJSON.getDouble("lat"), pointJSON.getDouble("lng")));
    }
    return path;
  }
  public static LatLngBounds JSONArray2LatLngBounds(JSONArray points) throws JSONException {
    List<LatLng> path = JSONArray2LatLngList(points);
    Builder builder = LatLngBounds.builder();
    int i = 0;
    for (i = 0; i < path.size(); i++) {
      builder.include(path.get(i));
    }
    return builder.build();
  }
}
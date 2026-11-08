// Portfolio 5: checks against the MongoDB Atlas cluster (a managed replica set).
// Run by atlas_demo.sh through mongosh.

const cb = db.getSiblingDB("carebridge");

print("=== 1. Is this a replica set? (db.hello) ===");
const h = db.hello();
print("replica set name : " + h.setName);
print("connected to     : " + h.me);
print("current primary  : " + h.primary);
print("members seen     : " + h.hosts.length);
h.hosts.forEach(function (m) { print("   - " + m); });

print("\n=== 2. Member roles (rs.status, may be restricted on a free cluster) ===");
try {
  rs.status().members.forEach(function (m) { print("   " + m.name + "  ->  " + m.stateStr); });
} catch (e) {
  print("   rs.status() is not available here: " + e.message);
}

print("\n=== 3. The imported data ===");
print(cb.patients.countDocuments({}) + " patient documents are in Atlas");

print("\n=== 4. A write that must reach the MAJORITY of nodes before it is confirmed ===");
const r = cb.patients.updateOne(
  { _id: 100 },
  { $set: { atlas_test: new Date() } },
  { writeConcern: { w: "majority", wtimeout: 10000 } }
);
printjson(r);

print("\n=== 5. Reading from the PRIMARY and from a SECONDARY (read preference) ===");
function hostFor(pref) {
  return cb.patients.find({ _id: 100 }).readPref(pref).explain("queryPlanner").serverInfo.host;
}
try {
  print("read preference 'primary'   was served by: " + hostFor("primary"));
  print("read preference 'secondary' was served by: " + hostFor("secondary"));
  const s = cb.patients.find({ _id: 100 }).readPref("secondary").next();
  print("the secondary returned patient " + s._id + " (" + s.first_name + " " + s.last_name + "), atlas_test = " + s.atlas_test);
} catch (e) {
  print("   secondary read failed: " + e.message);
}

// Portfolio 4: MongoDB queries on the CareBridge patient documents.
// Run by run_nosql_demo.sh through mongosh (database: carebridge, collection: patients).

const pts = db.patients;

print("=== 1. How many patient documents were imported? ===");
print(pts.countDocuments({}) + " patient documents");

print("\n=== 2. One patient's WHOLE record in a single read (patient 100) ===");
const p = pts.findOne({ _id: 100 });
print(p.first_name + " " + p.last_name + " has " + p.visits.length + " visits. Here is the first visit, with its doctor, diagnoses, prescriptions, lab orders and payments embedded:");
printjson(p.visits[0]);

print("\n=== 3. Everything patient 100 was prescribed, 5 most recent (the SQL version needs a 4-table join) ===");
printjson(pts.aggregate([
  { $match: { _id: 100 } },
  { $unwind: "$visits" },
  { $unwind: "$visits.prescriptions" },
  { $project: { _id: 0, visit_date: "$visits.visit_date", drug: "$visits.prescriptions.drug", dosage: "$visits.prescriptions.dosage" } },
  { $sort: { visit_date: -1 } },
  { $limit: 5 }
]).toArray());

print("\n=== 4. Five most common diagnoses across all patients ===");
printjson(pts.aggregate([
  { $unwind: "$visits" },
  { $unwind: "$visits.diagnoses" },
  { $group: { _id: "$visits.diagnoses.condition_name", cases: { $sum: 1 } } },
  { $sort: { cases: -1 } },
  { $limit: 5 }
]).toArray());

print("\n=== 5. Three patients who have paid the most in total ===");
printjson(pts.aggregate([
  { $project: {
      name: { $concat: ["$first_name", " ", "$last_name"] },
      visits: { $size: "$visits" },
      total_paid: { $sum: { $map: { input: "$visits", as: "v", in: { $sum: "$$v.payments.amount" } } } }
  } },
  { $sort: { total_paid: -1 } },
  { $limit: 3 }
]).toArray());

print("\n=== 6. Flexible schema: add a new field to ONE patient, no table change needed ===");
pts.updateOne({ _id: 100 }, { $set: { emergency_contact: { name: "Test Contact", phone: "08000000000" } } });
printjson(pts.findOne({ _id: 100 }, { first_name: 1, last_name: 1, emergency_contact: 1 }));
print(pts.countDocuments({ emergency_contact: { $exists: true } }) + " of " + pts.countDocuments({}) + " patients have this field. The rest are untouched and still valid.");

print("\n=== 7. Indexing: which patient does visit " + p.visits[1].visit_id + " belong to? (without and with an index) ===");
function stages(plan) { return plan.inputStage ? plan.stage + " > " + stages(plan.inputStage) : plan.stage; }
function show(label) {
  const e = pts.find({ "visits.visit_id": p.visits[1].visit_id }).explain("executionStats");
  print(label + ": plan = " + stages(e.queryPlanner.winningPlan) +
        ", documents examined = " + e.executionStats.totalDocsExamined +
        ", returned = " + e.executionStats.nReturned +
        ", time = " + e.executionStats.executionTimeMillis + " ms");
}
pts.dropIndexes();
show("WITHOUT index");
pts.createIndex({ "visits.visit_id": 1 });
show("WITH index   ");

print("\n=== 8. Document growth: the biggest patient document ===");
printjson(pts.aggregate([
  { $project: { name: { $concat: ["$first_name", " ", "$last_name"] }, visits: { $size: "$visits" }, size_bytes: { $bsonSize: "$$ROOT" } } },
  { $sort: { size_bytes: -1 } },
  { $limit: 1 }
]).toArray());
print("MongoDB's hard limit is 16,777,216 bytes (16 MB) per document.");

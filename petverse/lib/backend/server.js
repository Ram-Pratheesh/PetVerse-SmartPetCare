const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const cors = require("cors");
const multer = require("multer");
require("dotenv").config();

// ✅ Initialize Express App
const app = express();
app.use(express.json());
app.use(cors());

// ✅ Debug: Check if environment variables are set
if (!process.env.MONGO_URI || !process.env.SECRET_KEY) {
    console.error("❌ Missing environment variables! Check .env file.");
    process.exit(1);
}

// 📡 Connect to MongoDB
mongoose
    .connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log("✅ Connected to MongoDB Atlas"))
    .catch((err) => {
        console.error("❌ MongoDB Connection Error:", err);
        process.exit(1);
    });

// 🛠️ User Schema & Model
const UserSchema = new mongoose.Schema({
    username: { type: String, required: true },
    mobile: { type: String, required: true },
    email: { type: String, unique: true, required: true },
    password: { type: String, required: true },
});

const User = mongoose.model("User", UserSchema);

// 📩 Signup Route
app.post("/signup", async (req, res) => {
    const { username, mobile, email, password } = req.body;
    if (!username || !mobile || !email || !password) {
        return res.status(400).json({ error: "All fields are required!" });
    }

    try {
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ error: "Email already exists!" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({ username, mobile, email, password: hashedPassword });

        await newUser.save();
        res.json({ message: "User Registered Successfully!" });
    } catch (error) {
        console.error("❌ Signup error:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
});

// 🔑 Login Route
// 🔑 Login Route
app.post("/login", async (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) {
        return res.status(400).json({ error: "Email and password are required" });
    }

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ error: "User Not Found" });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ error: "Invalid Credentials" });
        }

        const token = jwt.sign({ email: user.email }, process.env.SECRET_KEY, { expiresIn: "1h" });

        // ✅ Now returns userId for client-side usage
        res.json({ username: user.username, token, userId: user._id });
    } catch (error) {
        console.error("❌ Login error:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
});


// 🐶 Pet Schema & Model
const PetSchema = new mongoose.Schema({
    petName: String,
    breed: String,
    description: String,
    color: String,
    lastSeenLocation: String,
    dateLost: String,
    contactInfo: String,
    imageUrl: String,
    identificationMark: String,
    status: { type: String, default: "Lost" },
    createdAt: { type: Date, default: Date.now }
});

const Pet = mongoose.model("Pet", PetSchema);

// 🐾 Add Lost Pet Route
app.post("/report-lost-pet", async (req, res) => {
    try {
        const { petName, breed, description, color, lastSeenLocation, dateLost, contactInfo, imageUrl, identificationMark } = req.body;

        if (!petName || !lastSeenLocation || !dateLost || !imageUrl) {
            return res.status(400).json({ error: "Missing required fields!" });
        }

        const newPet = new Pet({ petName, breed, description, color, lastSeenLocation, dateLost, contactInfo, imageUrl, identificationMark, status: "Lost" });

        await newPet.save();
        res.status(201).json({ message: "Lost pet report added!", pet: newPet });
    } catch (error) {
        console.error("❌ Error reporting lost pet:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
});

// 🐾 Report Found Pet Route
app.post("/report-found-pet", async (req, res) => {
    try {
        const { petName, breed, description, color, lastSeenLocation, dateLost, contactInfo, imageUrl, identificationMark } = req.body;

        if (!petName || !lastSeenLocation || !imageUrl) {
            return res.status(400).json({ error: "Missing required fields!" });
        }

        // Check if pet was reported lost
        const lostPet = await Pet.findOne({ identificationMark, breed, color, status: "Lost" });

        if (lostPet) {
            await Pet.deleteOne({ _id: lostPet._id });
            return res.status(200).json({ match_found: true, message: "Lost pet matched and removed from database!" });
        }

        const foundPet = new Pet({ petName, breed, description, color, lastSeenLocation, dateLost, contactInfo, imageUrl, identificationMark, status: "Found" });
        await foundPet.save();

        res.status(201).json({ match_found: false, message: "Found pet reported!", pet: foundPet });
    } catch (error) {
        console.error("❌ Error reporting found pet:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
});

// 🔎 Fetch All Lost Pets
app.get("/lost-pets", async (req, res) => {
    try {
        const pets = await Pet.find({ status: "Lost" });
        res.json(pets);
    } catch (error) {
        console.error("❌ Error fetching lost pets:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
});

// ✅ Health Check Route
app.get("/", (req, res) => {
    res.send("🚀 API is running!");
});

// 🚀 Start Server
const PORT = process.env.PORT || 5000;
const HOST = "0.0.0.0";
app.listen(PORT, HOST, () => {
    console.log(`✅ Server is running on http://0.0.0.0:${PORT}`);
});
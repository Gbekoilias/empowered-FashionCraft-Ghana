const mongoose = require('mongoose');

// Define the product schema
const productSchema = new mongoose.Schema({
    productName: {
        type: String,
        required: true,
        trim: true
    },
    price: {
        type: Number,
        required: true,
        min: 0 // Price must be a non-negative number
    },
    createdAt: {
        type: Date,
        default: Date.now // Automatically set the date when the product is created
    }
});

// Create a model based on the schema
const Product = mongoose.model('Product', productSchema);

// Export the Product model for use in other parts of the application
module.exports = Product;

// Example function to create a new product
async function createProduct(productName, price) {
    const product = new Product({ productName, price });
    try {
        const savedProduct = await product.save();
        console.log('Product saved:', savedProduct);
    } catch (error) {
        console.error('Error saving product:', error);
    }
}

// Example usage
if (require.main === module) {
    // Connect to MongoDB (update with your connection string)
    mongoose.connect('mongodb://localhost:27017/mydatabase', { useNewUrlParser: true, useUnifiedTopology: true })
        .then(() => {
            console.log('Connected to MongoDB');
            // Create a sample product
            createProduct('Sample Product', 19.99);
        })
        .catch(err => {
            console.error('MongoDB connection error:', err);
        });
}

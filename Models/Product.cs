using System.Text.Json.Serialization;

namespace backend_II.Models
{
    public class Product
    {
        public int ProductId { get; set; }
        public string SKU { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int StockQuantity { get; set; }

        [JsonIgnore]
        public bool IsActive { get; set; }

        [JsonIgnore]
        public DateTime CreatedAt { get; set; }
    }
}

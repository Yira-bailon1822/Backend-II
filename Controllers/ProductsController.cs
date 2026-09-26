using Microsoft.AspNetCore.Mvc;
using backend_II.Models;
using backend_II.Database;

namespace backend_II.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductsController : ControllerBase
    {
        private readonly ProductRepository _repository;

        public ProductsController(ProductRepository repository)
        {
            _repository = repository;
        }

        // GET: api/products
        [HttpGet]
        public async Task<GeneralResponse<List<Product>>> GetAll()
        {
            try
            {
                var products = await _repository.GetAllActiveProductsAsync();
                
                return new GeneralResponse<List<Product>>
                {
                    Success = true,
                    Message = "Productos obtenidos exitosamente.",
                    Data = products
                };
            }
            catch (Exception ex)
            {
                return new GeneralResponse<List<Product>> 
                { 
                    Success = false, 
                    Message = ex.Message, 
                    Data = null 
                };
            }
        }

        // GET: api/products/{sku}
        [HttpGet("{sku}")]
        public async Task<GeneralResponse<Product>> GetByRoute([FromRoute] string sku)
        {
            try
            {
                var product = await _repository.GetProductBySkuAsync(sku);
                
                if (product == null)
                {
                    return new GeneralResponse<Product>
                    {
                        Success = false,
                        Message = "Producto no encontrado o inactivo.",
                        Data = null
                    };
                }

                return new GeneralResponse<Product>
                {
                    Success = true,
                    Message = "Producto encontrado.",
                    Data = product
                };
            }
            catch (Exception ex)
            {
                return new GeneralResponse<Product> 
                { 
                    Success = false, 
                    Message = ex.Message, 
                    Data = null 
                };
            }
        }

        // GET: api/products/search?sku=XYZ
        [HttpGet("search")]
        public async Task<GeneralResponse<Product>> GetByQuery([FromQuery] string sku)
        {
            if (string.IsNullOrWhiteSpace(sku))
            {
                return new GeneralResponse<Product>
                {
                    Success = false,
                    Message = "El parámetro 'sku' en la URL es obligatorio.",
                    Data = null
                };
            }

            try
            {
                var product = await _repository.GetProductBySkuAsync(sku);

                if (product == null)
                {
                    return new GeneralResponse<Product>
                    {
                        Success = false,
                        Message = "Producto no encontrado o inactivo.",
                        Data = null
                    };
                }

                return new GeneralResponse<Product>
                {
                    Success = true,
                    Message = "Producto encontrado.",
                    Data = product
                };
            }
            catch (Exception ex)
            {
                return new GeneralResponse<Product> 
                { 
                    Success = false, 
                    Message = ex.Message, 
                    Data = null 
                };
            }
        }

        // POST: api/products/search
        [HttpPost("search")]
        public async Task<GeneralResponse<Product>> GetByBody([FromBody] ProductSearchRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Sku))
            {
                return new GeneralResponse<Product>
                {
                    Success = false,
                    Message = "El atributo 'sku' en el cuerpo (Body) de la petición es obligatorio.",
                    Data = null
                };
            }

            try
            {
                var product = await _repository.GetProductBySkuAsync(request.Sku);

                if (product == null)
                {
                    return new GeneralResponse<Product>
                    {
                        Success = false,
                        Message = "Producto no encontrado o inactivo.",
                        Data = null
                    };
                }

                return new GeneralResponse<Product>
                {
                    Success = true,
                    Message = "Producto encontrado.",
                    Data = product
                };
            }
            catch (Exception ex)
            {
                return new GeneralResponse<Product> 
                { 
                    Success = false, 
                    Message = ex.Message, 
                    Data = null 
                };
            }
        }
    }
}

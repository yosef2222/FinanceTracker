using System.Security.Claims;
using FinHelper.Models.Transaction;
using FinHelper.Services.Category;
using FinHelper.Services.TransactionParser;
using Microsoft.AspNetCore.Mvc;

namespace FinHelper.Controllers;

[ApiController]
[Route("api/ai")]
public class AITransactionController : BaseController
{
    private readonly ITransactionParserService _parserService;
    private readonly ITransactionService _transactionService;
    private readonly ICategoryService _categoryService;

    public AITransactionController(
        ITransactionParserService parserService,
        ITransactionService transactionService,
        ICategoryService categoryService)
    {
        _parserService = parserService;
        _transactionService = transactionService;
        _categoryService = categoryService;
    }

    [HttpPost("parse-transaction")]
    public async Task<ActionResult<TransactionResponseDto>> CreateTransactionFromPrompt(
        [FromBody] TransactionParseRequest request)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        try
        {
            // Get current user ID from base controller
            var userId = UserId;

            // Get all categories
            var categories = await _categoryService.GetAllCategoriesAsync();

            // Parse transaction from prompt
            var parsedTransaction = await _parserService.ParseTransactionAsync(
                request.Prompt,
                categories);

            // Check for fallback result
            if (parsedTransaction.IsFallback)
            {
                return BadRequest(new
                {
                    Message = "Couldn't parse transaction details",
                    Suggestion = new
                    {
                        parsedTransaction.Amount,
                        parsedTransaction.Merchant,
                        parsedTransaction.Description,
                        CategoryId = parsedTransaction.CategoryId
                    },
                    Categories = categories.Select(c => new { c.Id, c.Name })
                });
            }

            // Create transaction DTO
            var transactionDto = new TransactionDto
            {
                Amount = parsedTransaction.Amount,
                Merchant = parsedTransaction.Merchant,
                Description = parsedTransaction.Description,
                CategoryId = parsedTransaction.CategoryId,
                Date = parsedTransaction.Date
            };

            // Create actual transaction
            var createdTransaction = await _transactionService.CreateTransaction(
                userId,
                transactionDto);

            // Return the created transaction
            return StatusCode(StatusCodes.Status201Created, createdTransaction);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(ex.Message);
        }
        catch (FormatException ex)
        {
            return BadRequest(ex.Message);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Error creating transaction: {ex.Message}");
        }
    }
}
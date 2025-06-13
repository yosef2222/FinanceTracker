using System.Security.Claims;
using FinHelper.Models.Transaction;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinHelper.Controllers;

[Authorize]
[ApiController]
[Route("api/transactions")]
public class TransactionsController : ControllerBase
{
    private readonly ITransactionService _transactionService;
    private Guid UserId => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));

    public TransactionsController(ITransactionService transactionService)
    {
        _transactionService = transactionService;
    }

    [HttpPost]
    public async Task<IActionResult> CreateTransaction(TransactionDto dto)
    {
        var transaction = await _transactionService.CreateTransaction(UserId, dto);
        return CreatedAtAction(nameof(GetTransaction), new { id = transaction.Id }, transaction);
    }

    [HttpPut]
    public async Task<IActionResult> UpdateTransaction(TransactionDto dto)
    {
        var transaction = await _transactionService.UpdateTransaction(UserId, dto);
        return Ok(transaction);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteTransaction(Guid id)
    {
        await _transactionService.DeleteTransaction(UserId, id);
        return NoContent();
    }

    [HttpGet]
    public async Task<IActionResult> GetTransactions(
        [FromQuery] DateTime? startDate, 
        [FromQuery] DateTime? endDate)
    {
        var transactions = await _transactionService.GetTransactions(UserId, startDate, endDate);
        return Ok(transactions);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetTransaction(Guid id)
    {
        var transactions = await _transactionService.GetTransactions(UserId, null, null);
        var transaction = transactions.FirstOrDefault(t => t.Id == id);
        if (transaction == null) return NotFound();
        return Ok(transaction);
    }
}
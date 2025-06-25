using System.Security.Claims;
using FinHelper.Models.User;
using FinHelper.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinHelper.Controllers;

[Authorize]
[ApiController]
[Route("api/loans")]
public class LoansController : ControllerBase
{
    private readonly ILoanService _loanService;
    private Guid UserId => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));

    public LoansController(ILoanService loanService)
    {
        _loanService = loanService;
    }

    [HttpPost]
    public async Task<IActionResult> AddLoan(LoanDto dto)
    {
        var loan = await _loanService.AddLoan(UserId, dto);
        return CreatedAtAction(nameof(GetLoan), new { id = loan.Id }, loan);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateLoan(Guid id, LoanDto dto)
    {
        var loan = await _loanService.UpdateLoan(UserId, id, dto);
        return Ok(loan);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteLoan(Guid id)
    {
        await _loanService.DeleteLoan(UserId, id);
        return NoContent();
    }

    [HttpGet]
    public async Task<IActionResult> GetLoans()
    {
        var loans = await _loanService.GetLoans(UserId);
        return Ok(loans);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetLoan(Guid id)
    {
        var loan = await _loanService.GetLoan(UserId, id);
        return Ok(loan);
    }

    [HttpGet("active")]
    public async Task<IActionResult> GetActiveLoans()
    {
        var loans = await _loanService.GetActiveLoans(UserId);
        return Ok(loans);
    }

    [HttpGet("monthly-payment")]
    public async Task<IActionResult> GetTotalMonthlyPayment()
    {
        var total = await _loanService.GetTotalMonthlyPayment(UserId);
        return Ok(new { TotalMonthlyPayment = total });
    }
}
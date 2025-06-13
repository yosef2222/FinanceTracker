using System.Security.Claims;
using FinHelper.Models.Budget;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinHelper.Controllers;

[Authorize]
[ApiController]
[Route("api/budgets")]
public class BudgetsController : ControllerBase
{
    private readonly IBudgetService _budgetService;
    private Guid UserId => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));

    public BudgetsController(IBudgetService budgetService)
    {
        _budgetService = budgetService;
    }

    [HttpPost]
    public async Task<IActionResult> CreateBudget(BudgetDto dto)
    {
        var budget = await _budgetService.CreateBudget(UserId, dto);
        return CreatedAtAction(nameof(GetBudget), new { id = budget.Id }, budget);
    }

    [HttpPut]
    public async Task<IActionResult> UpdateBudget(BudgetDto dto)
    {
        var budget = await _budgetService.UpdateBudget(UserId, dto);
        return Ok(budget);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteBudget(Guid id)
    {
        await _budgetService.DeleteBudget(UserId, id);
        return NoContent();
    }

    [HttpGet]
    public async Task<IActionResult> GetBudgets()
    {
        var budgets = await _budgetService.GetBudgets(UserId);
        return Ok(budgets);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetBudget(Guid id)
    {
        var budget = await _budgetService.GetBudget(UserId, id);
        return Ok(budget);
    }
}
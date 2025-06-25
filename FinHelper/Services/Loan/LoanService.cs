using FinHelper.Data;
using FinHelper.Models.User;
using Microsoft.EntityFrameworkCore;

namespace FinHelper.Services;

public class LoanService : ILoanService
{
    private readonly ApplicationDbContext _context;

    public LoanService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Loan> AddLoan(Guid userId, LoanDto dto)
    {
        var loan = new Loan
        {
            UserId = userId,
            Amount = dto.Amount,
            TermMonths = dto.TermMonths,
            MonthlyPayment = dto.MonthlyPayment,
            Type = dto.Type,
            StartDate = dto.StartDate,
            IsActive = true
        };

        await _context.Loans.AddAsync(loan);
        await _context.SaveChangesAsync();
        return loan;
    }

    public async Task<Loan> UpdateLoan(Guid userId, Guid loanId, LoanDto dto)
    {
        var loan = await _context.Loans
            .FirstOrDefaultAsync(l => l.Id == loanId && l.UserId == userId);

        if (loan == null)
            throw new KeyNotFoundException("Loan not found");

        loan.Amount = dto.Amount;
        loan.TermMonths = dto.TermMonths;
        loan.MonthlyPayment = dto.MonthlyPayment;
        loan.Type = dto.Type;
        loan.StartDate = dto.StartDate;
        loan.IsActive = dto.IsActive;

        await _context.SaveChangesAsync();
        return loan;
    }

    public async Task DeleteLoan(Guid userId, Guid loanId)
    {
        var loan = await _context.Loans
            .FirstOrDefaultAsync(l => l.Id == loanId && l.UserId == userId);

        if (loan == null)
            throw new KeyNotFoundException("Loan not found");

        _context.Loans.Remove(loan);
        await _context.SaveChangesAsync();
    }

    public async Task<List<Loan>> GetLoans(Guid userId)
    {
        return await _context.Loans
            .Where(l => l.UserId == userId)
            .OrderByDescending(l => l.StartDate)
            .ToListAsync();
    }

    public async Task<Loan> GetLoan(Guid userId, Guid loanId)
    {
        return await _context.Loans
            .FirstOrDefaultAsync(l => l.Id == loanId && l.UserId == userId)
            ?? throw new KeyNotFoundException("Loan not found");
    }

    public async Task<List<Loan>> GetActiveLoans(Guid userId)
    {
        return await _context.Loans
            .Where(l => l.UserId == userId && l.IsActive)
            .OrderByDescending(l => l.StartDate)
            .ToListAsync();
    }

    public async Task<decimal> GetTotalMonthlyPayment(Guid userId)
    {
        return await _context.Loans
            .Where(l => l.UserId == userId && l.IsActive)
            .SumAsync(l => l.MonthlyPayment);
    }

    public async Task<List<Loan>> GetLoansByType(Guid userId, string type)
    {
        return await _context.Loans
            .Where(l => l.UserId == userId && l.Type.ToLower() == type.ToLower())
            .ToListAsync();
    }

    public async Task<int> GetActiveLoansCount(Guid userId)
    {
        return await _context.Loans
            .CountAsync(l => l.UserId == userId && l.IsActive);
    }
}
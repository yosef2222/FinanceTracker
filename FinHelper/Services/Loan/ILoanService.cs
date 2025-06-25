using FinHelper.Models.User;

namespace FinHelper.Services;

public interface ILoanService
{
    Task<Loan> AddLoan(Guid userId, LoanDto dto);
    Task<Loan> UpdateLoan(Guid userId, Guid loanId, LoanDto dto);
    Task DeleteLoan(Guid userId, Guid loanId);
    Task<List<Loan>> GetLoans(Guid userId);
    Task<Loan> GetLoan(Guid userId, Guid loanId);
    Task<List<Loan>> GetActiveLoans(Guid userId);
    Task<decimal> GetTotalMonthlyPayment(Guid userId);
}
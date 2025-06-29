namespace FinHelper.Models.User;

public class UserProfileDto
{
    public string FullName { get; set; }
    public string Email { get; set; }
    public DateTime BirthDate { get; set; }
    public decimal Salary { get; set; }
    public decimal Cushion { get; set; }
    public string FinancialGoal { get; set; }
    public List<LoanDto> Loans { get; set; } = new(); // Список кредитов
}
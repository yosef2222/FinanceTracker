namespace FinHelper.Models;

public class User
{
    public Guid Id { get; set; }
    public string FullName { get; set; }
    public DateTime Birthday { get; set; }
    public string Email { get; set; }
    public string PasswordHash { get; set; }

}
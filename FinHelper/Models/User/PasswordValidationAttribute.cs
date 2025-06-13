using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;
namespace FinHelper.Models.User;

public class PasswordValidationAttribute : ValidationAttribute
{
    protected override ValidationResult IsValid(object value, ValidationContext validationContext)
    {
        var password = value as string;
        if (string.IsNullOrEmpty(password))
        {
            return new ValidationResult("Password is required.");
        }
        
        if (!Regex.IsMatch(password, @"\d"))
        {
            return new ValidationResult("Password must contain at least one digit.");
        }

        return ValidationResult.Success;
    }
}
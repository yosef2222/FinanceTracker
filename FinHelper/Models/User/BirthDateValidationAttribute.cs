using System.ComponentModel.DataAnnotations;
namespace FinHelper.Models.User;

public class BirthDateValidationAttribute : ValidationAttribute
{
    protected override ValidationResult IsValid(object value, ValidationContext validationContext)
    {
        var birthDate = (DateTime)value;
        
        if (birthDate > DateTime.Now)
        {
            return new ValidationResult("Birth date cannot be in the future.");
        }

        return ValidationResult.Success;
    }
}
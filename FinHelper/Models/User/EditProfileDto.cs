using System.ComponentModel.DataAnnotations;

namespace FinHelper.Models.User;

public class EditProfileDto
{
    [Required]
    public string FullName { get; set; }

    [Required]
    [DataType(DataType.Date)]
    [BirthDateValidation(ErrorMessage = "Birthday cannot be in the future.")]
    public DateTime BirthDate { get; set; }
    
}


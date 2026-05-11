using Microsoft.AspNetCore.Identity;

namespace TodoApi.Models;

public class ApplicationUser : IdentityUser
{
    public ICollection<TodoItem>? Todos { get; set; }
}
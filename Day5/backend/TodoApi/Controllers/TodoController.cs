using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;         
using Microsoft.AspNetCore.Identity;          
using TodoApi.Data;
using TodoApi.Models;

namespace TodoApi.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]  // 🔐 Yêu cầu JWT Token
public class TodoController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly UserManager<ApplicationUser> _userManager;  // ✅ Giờ đã nhận diện được

    public TodoController(AppDbContext context, UserManager<ApplicationUser> userManager)
    {
        _context = context;
        _userManager = userManager;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<TodoItem>>> GetTodos()
    {
        var userId = _userManager.GetUserId(User);
        return await _context.Todos
            .Where(t => t.UserId == userId)
            .ToListAsync();
    }

    [HttpPost]
    public async Task<ActionResult<TodoItem>> CreateTodo([FromBody] CreateTodoDto dto)
    {
        var userId = _userManager.GetUserId(User);
        var todo = new TodoItem 
        { 
            Title = dto.Title, 
            Description = dto.Description, 
            UserId = userId 
        };
        
        _context.Todos.Add(todo);
        await _context.SaveChangesAsync();  // ✅ Fix lỗi CS1061: SaveChangesAsync
        
        return CreatedAtAction(nameof(GetTodos), new { id = todo.Id }, todo);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateTodo(int id, [FromBody] UpdateTodoDto dto)
    {
        var userId = _userManager.GetUserId(User);
        var todo = await _context.Todos.FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);
        
        if (todo == null) return NotFound();
        
        todo.Title = dto.Title ?? todo.Title;
        todo.Description = dto.Description ?? todo.Description;
        todo.IsCompleted = dto.IsCompleted ?? todo.IsCompleted;
        
        await _context.SaveChangesAsync();  // ✅ Fix lỗi
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteTodo(int id)
    {
        var userId = _userManager.GetUserId(User);
        var todo = await _context.Todos.FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);
        
        if (todo == null) return NotFound();
        
        _context.Todos.Remove(todo);
        await _context.SaveChangesAsync();  // ✅ Fix lỗi
        return NoContent();
    }
}

// DTOs
public class CreateTodoDto 
{ 
    public string Title { get; set; } = string.Empty; 
    public string? Description { get; set; } 
}

public class UpdateTodoDto 
{ 
    public string? Title { get; set; } 
    public string? Description { get; set; } 
    public bool? IsCompleted { get; set; } 
}
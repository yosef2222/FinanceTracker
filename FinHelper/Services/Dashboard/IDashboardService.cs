using FinHelper.Models.Dashboard;

namespace FinHelper.Services.Dashboard;

public interface IDashboardService
{
    Task<DashboardResponseDto> GetDashboard(Guid userId);
}
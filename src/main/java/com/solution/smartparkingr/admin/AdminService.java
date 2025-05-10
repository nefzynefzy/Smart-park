package com.solution.smartparkingr.admin;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.solution.smartparkingr.admin.dto.*;
import com.solution.smartparkingr.model.*;
import com.solution.smartparkingr.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.solution.smartparkingr.model.ReservationStatus;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class AdminService {
    private final UserRepository userRepository;
    private final ReservationRepository reservationRepository;
    private final ParkingSpotRepository parkingSpotRepository;
    private final ParkingSettingsRepository parkingSettingsRepository;
    private final SubscriptionRepository subscriptionRepository;
    private final SubscriptionPlanRepository subscriptionPlanRepository;
    private final ObjectMapper objectMapper;

    private final List<Map<String, Object>> settingsHistory = new ArrayList<>();

    public AnalyticsDataDTO getAnalyticsData() {
        AnalyticsDataDTO analytics = new AnalyticsDataDTO();

        long totalReservations = reservationRepository.count();
        analytics.setTotalReservations((int) totalReservations);

        double totalRevenue = reservationRepository.findAll().stream()
                .filter(r -> r.getTotalCost() != null)
                .mapToDouble(Reservation::getTotalCost)
                .sum();
        analytics.setTotalRevenue(totalRevenue);

        LocalDateTime todayStart = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0);
        LocalDateTime todayEnd = LocalDateTime.now().withHour(23).withMinute(59).withSecond(59);
        double dailyRevenue = reservationRepository.findByStartTimeBetween(todayStart, todayEnd).stream()
                .filter(r -> r.getTotalCost() != null)
                .mapToDouble(Reservation::getTotalCost)
                .sum();
        analytics.setDailyRevenue(dailyRevenue);

        List<Long> activeUserIds = reservationRepository.findByStatusNotIn(
                        List.of(ReservationStatus.CANCELLED, ReservationStatus.EXPIRED)
                ).stream()
                .map(r -> r.getUser().getId())
                .distinct()
                .collect(Collectors.toList());
        analytics.setActiveUsers(activeUserIds.size());

        List<Long> vehiclesToday = reservationRepository.findByStartTimeBetween(todayStart, todayEnd).stream()
                .filter(r -> r.getVehicle() != null)
                .map(r -> r.getVehicle().getId())
                .distinct()
                .collect(Collectors.toList());
        analytics.setTotalVehicles(vehiclesToday.size());

        double averageParkingTime = reservationRepository.findAll().stream()
                .filter(r -> r.getStartTime() != null && r.getEndTime() != null)
                .mapToDouble(r -> ChronoUnit.MINUTES.between(r.getStartTime(), r.getEndTime()) / 60.0)
                .average()
                .orElse(0.0);
        analytics.setAverageParkingTime(averageParkingTime);

        long occupiedSpots = parkingSpotRepository.findAll().stream()
                .filter(spot -> !spot.isAvailable())
                .count();
        int totalSpots = (int) parkingSpotRepository.count();
        double occupancyRate = totalSpots > 0 ? (double) occupiedSpots / totalSpots * 100 : 0;
        analytics.setOccupancyRate(occupancyRate);

        Map<String, Object> chartDataMap = getChartData("week");
        @SuppressWarnings("unchecked")
        List<ChartDataDTO> chartDataList = (List<ChartDataDTO>) chartDataMap.get("data");
        analytics.setReservationsByDay(chartDataList);

        return analytics;
    }

    public Map<String, Object> getChartData(String period) {
        List<ChartDataDTO> chartData = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter hourFormatter = DateTimeFormatter.ofPattern("HH:00");

        if (period.equals("day")) {
            int totalSpots = (int) parkingSpotRepository.count();
            for (int i = 0; i < 24; i++) {
                LocalDateTime hourStart = now.minusHours(24 - i);
                long occupiedSpots = reservationRepository.findByStatus(ReservationStatus.CONFIRMED).stream()
                        .filter(r -> r.getStartTime().isAfter(hourStart) && r.getStartTime().isBefore(hourStart.plusHours(1)))
                        .count();
                double rate = totalSpots > 0 ? (double) occupiedSpots / totalSpots * 100 : 0;
                ChartDataDTO data = new ChartDataDTO();
                data.setHour(hourStart.format(hourFormatter));
                data.setRate(rate);
                chartData.add(data);
            }
        } else {
            int days = period.equals("week") ? 7 : 30;
            for (int i = 0; i < days; i++) {
                LocalDateTime dayStart = now.minusDays(days - i);
                LocalDateTime dayEnd = dayStart.plusDays(1);
                double revenue = reservationRepository.findByStartTimeBetween(dayStart, dayEnd).stream()
                        .filter(r -> r.getTotalCost() != null)
                        .mapToDouble(Reservation::getTotalCost)
                        .sum();
                ChartDataDTO data = new ChartDataDTO();
                data.setDate(dayStart.format(dateFormatter));
                data.setRevenue(revenue);
                chartData.add(data);
            }
        }

        Map<String, Object> response = new HashMap<>();
        response.put("data", chartData);
        return response;
    }

    public List<Map<String, String>> getNotifications() {
        return List.of(
                Map.of("message", "Nouvelle réservation", "timestamp", LocalDateTime.now().toString()),
                Map.of("message", "Maintenance planifiée", "timestamp", LocalDateTime.now().toString())
        );
    }

    public List<UserDTO> getUsers() {
        return userRepository.findAll().stream()
                .map(this::mapToUserDTO)
                .collect(Collectors.toList());
    }

    public UserDTO getUserById(Long id) {
        return userRepository.findById(id)
                .map(this::mapToUserDTO)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé : " + id));
    }

    @Transactional
    public UserDTO createUser(UserDTO userDTO) {
        if (userRepository.existsByEmail(userDTO.getEmail()) || userRepository.existsByPhone(userDTO.getPhone())) {
            throw new RuntimeException("Email ou téléphone déjà utilisé");
        }

        User user = new User();
        user.setFirstName(userDTO.getFirstName());
        user.setLastName(userDTO.getLastName());
        user.setEmail(userDTO.getEmail());
        user.setPhone(userDTO.getPhone());
        user.setPassword(userDTO.getPassword()); // À encoder avec BCrypt
        user.setActive(userDTO.isActive());
        user.setCoordinates(mapToCoordinates(userDTO.getCoordinates()));

        // Gérer le rôle
        Role role = new Role();
        role.setName(ERole.valueOf("ROLE_" + userDTO.getRole().toUpperCase()));
        user.setRoles(Set.of(role));

        user = userRepository.save(user);
        return mapToUserDTO(user);
    }

    @Transactional
    public UserDTO updateUser(Long id, UserDTO userDTO) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé : " + id));

        if (!user.getEmail().equals(userDTO.getEmail()) && userRepository.existsByEmail(userDTO.getEmail())) {
            throw new RuntimeException("Email déjà utilisé");
        }
        if (!user.getPhone().equals(userDTO.getPhone()) && userRepository.existsByPhone(userDTO.getPhone())) {
            throw new RuntimeException("Téléphone déjà utilisé");
        }

        user.setFirstName(userDTO.getFirstName());
        user.setLastName(userDTO.getLastName());
        user.setEmail(userDTO.getEmail());
        user.setPhone(userDTO.getPhone());
        if (userDTO.getPassword() != null && !userDTO.getPassword().isEmpty()) {
            user.setPassword(userDTO.getPassword()); // À encoder
        }
        user.setActive(userDTO.isActive());
        user.setCoordinates(mapToCoordinates(userDTO.getCoordinates()));

        // Gérer le rôle
        Role role = new Role();
        role.setName(ERole.valueOf("ROLE_" + userDTO.getRole().toUpperCase()));
        user.setRoles(Set.of(role));

        user = userRepository.save(user);
        return mapToUserDTO(user);
    }

    @Transactional
    public void deleteUser(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé : " + id));
        userRepository.delete(user);
    }

    public List<ReservationDTO> getUserReservations(Long userId) {
        return reservationRepository.findByUserId(userId).stream()
                .map(this::mapToReservationDTO)
                .collect(Collectors.toList());
    }

    public ParkingSettingsDTO getParkingSettings() {
        ParkingSettings settings = parkingSettingsRepository.findById(1L)
                .orElseGet(() -> {
                    ParkingSettings newSettings = new ParkingSettings();
                    newSettings.setMaxSlots((int) parkingSpotRepository.count());
                    newSettings.setHourlyRate(parkingSpotRepository.findAll().stream()
                            .mapToDouble(ParkingSpot::getPrice)
                            .average()
                            .orElse(0.0));
                    newSettings.setReservedPremiumSlots((int) parkingSpotRepository.findAll().stream()
                            .filter(spot -> "premium".equalsIgnoreCase(spot.getType()))
                            .count());
                    OperatingHours hours = new OperatingHours();
                    hours.setOpen("08:00");
                    hours.setClose("20:00");
                    newSettings.setOperatingHours(hours);
                    newSettings.setMaintenanceMode(false);
                    return parkingSettingsRepository.save(newSettings);
                });

        ParkingSettingsDTO dto = mapToParkingSettingsDTO(settings);
        List<SubscriptionPlan> plans = subscriptionPlanRepository.findAll();
        List<SubscriptionOfferDTO> offers = plans.stream().map(this::mapToSubscriptionOfferDTO).collect(Collectors.toList());
        dto.setSubscriptionOffers(offers);
        return dto;
    }

    @Transactional
    public ParkingSettingsDTO saveParkingSettings(ParkingSettingsDTO settingsDTO) {
        ParkingSettings settings = parkingSettingsRepository.findById(1L)
                .orElse(new ParkingSettings());
        settings.setMaxSlots(settingsDTO.getMaxSlots());
        settings.setHourlyRate(settingsDTO.getHourlyRate());
        settings.setReservedPremiumSlots(settingsDTO.getReservedPremiumSlots());
        settings.setOperatingHours(mapToOperatingHours(settingsDTO.getOperatingHours()));
        settings.setMaintenanceMode(settingsDTO.isMaintenanceMode());
        settings = parkingSettingsRepository.save(settings);

        for (SubscriptionOfferDTO offerDTO : settingsDTO.getSubscriptionOffers()) {
            SubscriptionPlan plan = subscriptionPlanRepository.findById(offerDTO.getId())
                    .orElse(new SubscriptionPlan());
            plan.setType(offerDTO.getName());
            plan.setMonthlyPrice(offerDTO.getPrice());
            plan.setParkingDurationLimit(offerDTO.getDuration());
            plan.setHasPremiumSpots(offerDTO.getName().equalsIgnoreCase("Premium") || offerDTO.getName().equalsIgnoreCase("Entreprise"));
            plan.setHasValetService(offerDTO.getName().equalsIgnoreCase("Entreprise"));
            plan.setSupportLevel(offerDTO.getName().equalsIgnoreCase("Entreprise") ? "DEDICATED" : "STANDARD");
            plan.setRemainingPlacesPerMonth(offerDTO.getSubscribers());
            subscriptionPlanRepository.save(plan);
        }

        Map<String, Object> historyEntry = new HashMap<>();
        historyEntry.put("timestamp", LocalDateTime.now().toString());
        historyEntry.put("changes", settingsDTO);
        settingsHistory.add(historyEntry);

        return mapToParkingSettingsDTO(settings);
    }

    public List<Map<String, Object>> getSettingsHistory() {
        return settingsHistory;
    }

    public String exportSettings() throws Exception {
        ParkingSettingsDTO settings = getParkingSettings();
        return objectMapper.writeValueAsString(settings);
    }

    public RevenueEstimateDTO estimateRevenue() {
        RevenueEstimateDTO estimate = new RevenueEstimateDTO();

        LocalDateTime monthStart = LocalDateTime.now().minusDays(30);
        LocalDateTime monthEnd = LocalDateTime.now();

        // Convertir LocalDateTime en LocalDate pour la comparaison avec startDate
        LocalDate monthStartDate = monthStart.toLocalDate();
        LocalDate monthEndDate = monthEnd.toLocalDate();

        double monthlyReservationRevenue = reservationRepository.findByStartTimeBetween(monthStart, monthEnd).stream()
                .filter(r -> r.getTotalCost() != null)
                .mapToDouble(Reservation::getTotalCost)
                .sum();
        double monthlySubscriptionRevenue = subscriptionRepository.findAll().stream()
                .filter(s -> s.getStartDate() != null && s.getStartDate().isAfter(monthStartDate) && s.getStartDate().isBefore(monthEndDate))
                .filter(s -> s.getPrice() != null)
                .mapToDouble(Subscription::getPrice)
                .sum();
        estimate.setMonthly(monthlyReservationRevenue + monthlySubscriptionRevenue);

        estimate.setAnnual(estimate.getMonthly() * 12);

        return estimate;
    }

    public UserDTO mapToUserDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setName(user.getFirstName() + " " + user.getLastName());
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setEmail(user.getEmail());
        dto.setPhone(user.getPhone());
        dto.setPassword(user.getPassword());
        dto.setRole(user.getRoles().stream()
                .findFirst()
                .map(r -> r.getName().name().replace("ROLE_", ""))
                .orElse("Utilisateur"));
        dto.setActive(user.isActive());
        dto.setCoordinates(mapToCoordinatesDTO(user.getCoordinates()));
        return dto;
    }

    public ReservationDTO mapToReservationDTO(Reservation reservation) {
        ReservationDTO dto = new ReservationDTO();
        dto.setId(reservation.getId());
        dto.setUserId(reservation.getUser() != null ? reservation.getUser().getId() : null);
        dto.setSlotId(reservation.getParkingSpot() != null ? reservation.getParkingSpot().getId() : null);
        dto.setStartTime(reservation.getStartTime() != null ? reservation.getStartTime().toString() : null);
        dto.setEndTime(reservation.getEndTime() != null ? reservation.getEndTime().toString() : null);
        dto.setStatus(reservation.getStatus() != null ? reservation.getStatus().name().toLowerCase() : null);
        dto.setCost(reservation.getTotalCost());
        return dto;
    }

    public ParkingSettingsDTO mapToParkingSettingsDTO(ParkingSettings settings) {
        ParkingSettingsDTO dto = new ParkingSettingsDTO();
        dto.setId(settings.getId());
        dto.setMaxSlots(settings.getMaxSlots());
        dto.setHourlyRate(settings.getHourlyRate());
        dto.setReservedPremiumSlots(settings.getReservedPremiumSlots());
        dto.setOperatingHours(mapToOperatingHoursDTO(settings.getOperatingHours()));
        dto.setMaintenanceMode(settings.isMaintenanceMode());
        return dto;
    }

    public SubscriptionOfferDTO mapToSubscriptionOfferDTO(SubscriptionPlan plan) {
        SubscriptionOfferDTO dto = new SubscriptionOfferDTO();
        dto.setId(plan.getId());
        dto.setName(plan.getType());
        dto.setPrice(plan.getMonthlyPrice());
        dto.setDuration(plan.getParkingDurationLimit() != null ? plan.getParkingDurationLimit() : 30);
        dto.setActive(plan.getRemainingPlacesPerMonth() > 0);
        dto.setSubscribers(subscriptionRepository.findBySubscriptionType(plan.getType()).size());
        return dto;
    }

    private CoordinatesDTO mapToCoordinatesDTO(Coordinates coordinates) {
        if (coordinates == null) return null;
        CoordinatesDTO dto = new CoordinatesDTO();
        dto.setLatitude(coordinates.getLatitude());
        dto.setLongitude(coordinates.getLongitude());
        return dto;
    }

    private Coordinates mapToCoordinates(CoordinatesDTO dto) {
        if (dto == null) return null;
        Coordinates coordinates = new Coordinates();
        coordinates.setLatitude(dto.getLatitude());
        coordinates.setLongitude(dto.getLongitude());
        return coordinates;
    }

    private OperatingHoursDTO mapToOperatingHoursDTO(OperatingHours hours) {
        if (hours == null) return null;
        OperatingHoursDTO dto = new OperatingHoursDTO();
        dto.setOpen(hours.getOpen());
        dto.setClose(hours.getClose());
        return dto;
    }

    private OperatingHours mapToOperatingHours(OperatingHoursDTO dto) {
        if (dto == null) return null;
        OperatingHours hours = new OperatingHours();
        hours.setOpen(dto.getOpen());
        hours.setClose(dto.getClose());
        return hours;
    }
}
#' @section Development:
#' 20231111: Adapting from COMET for BOLD. JC
#' 


#library(gt)
library(gtsummary)
#library(ggpmisc)

##### Screening Selection #####
screened <- bold %>% filter(!is.na(scrn_date))
not_screened <- anti_join(bold, screened, by = "record_id")

##### Screening Status ######
#All screened participants are filtered into statuses
#A dataframe is kept (remaining) that stores participants
#Participants are removed from the remaining df as they are given a screening status
#Any participants left in the remaining df are likely errors and need to be looked into
screen_failed <- screened %>% filter(screening_status == 2)
remaining <- anti_join(screened, screen_failed, by = "record_id")

eligible <- remaining %>% filter(screening_status == 1)
remaining <- anti_join(remaining, eligible, by = "record_id")

on_hold <- remaining %>% filter(screening_status == 3)
remaining <- anti_join(remaining, on_hold, by = "record_id")

still_screening <- remaining %>% filter(!is.na(scrn_date) & is.na(screening_status))
remaining <- anti_join(remaining, still_screening, by = "record_id")


#### Screen Fail Reasons ####
to_join <- look_up_table %>%
  filter(field == "ieq_scrnfail_rsn") %>%
  select(-field)

screen_fail_reason_temp <- screen_failed %>%
  left_join(., to_join, by = c('ieq_scrnfail_rsn' = 'id_num')) %>%
  rename(Reason = "id_name")

screen_fail_reason <- screen_fail_reason_temp %>%
  select(Reason)

phone_screen_mistakes <- screen_fail_reason %>%
  filter(is.na(Reason))

screen_fail_gt <- gtsummary::tbl_summary(screen_fail_reason) 
string <- screen_fail_gt$table_body %>%
  select(label, stat_0) %>%
  filter(label != "Reason") %>%
  unite(reason, c("label","stat_0"), sep = " - " ) %>%
  unlist() %>%
  paste0(., collapse = "\n")


#### Second part of consort Diagram #####
consented <- eligible %>% filter(!is.na(consent_date))
remaining_2 <- anti_join(eligible, consented, by = "record_id")

expected_to_consent <- remaining_2

##### Third part of consort diagram
randomized <- consented %>% filter(!is.na(rand_date))
remaining_3 <- anti_join(consented, randomized, by = "record_id")

screen_failed_after_consent <- remaining_3 %>% filter(baseline_status == 3)
remaining_3 <- anti_join(remaining_3, screen_failed_after_consent, by = "record_id")

in_baseline <- remaining_3 %>% filter(!is.na(consent_date) & is.na(rand_date))
remaining_3 <- anti_join(remaining_3, in_baseline, by = "record_id")


#### Post-consent screen-fail Reasons ####
to_join_1 <- look_up_table %>%
  filter(field == "baseline_scrnfail_ie") %>%
  select(-field)

to_join_2 <- look_up_table %>%
  filter(field == "baseline_scrnfail_nocont") %>%
  select(-field)

screen_fail_after_consent_reason_temp <- screen_failed_after_consent %>%
  left_join(., to_join_1, by = c('baseline_scrnfail_ie' = 'id_num')) %>%
  rename(rsn_1 = "id_name") %>%
  left_join(., to_join_2, by = c('baseline_scrnfail_nocont' = 'id_num')) %>%
  mutate(Reason = case_when(!is.na(rsn_1) ~ rsn_1,
                            !is.na(id_name) ~ id_name))

screen_fail_after_consent_reason <- screen_fail_after_consent_reason_temp %>%
  select(Reason)

screen_fail_gt_2 <- gtsummary::tbl_summary(screen_fail_after_consent_reason) 
string_2 <- screen_fail_gt_2$table_body %>%
  select(label, stat_0) %>%
  filter(label != "Reason") %>%
  unite(reason, c("label","stat_0"), sep = " - " ) %>%
  unlist() %>%
  paste0(., collapse = "\n") 

##### Fourth part of consort diagram  #####
active <- randomized %>% filter(intervention_status == 1 | is.na(intervention_status))
remaining_4 <- anti_join(randomized, active, by = "record_id")

completed <- remaining_4 %>% filter(intervention_status == 2)
remaining_4 <- anti_join(remaining_4, completed, by = "record_id")

withdrawn_testing <- remaining_4 %>% filter(intervention_status == 3)
remaining_4 <- anti_join(remaining_4, withdrawn_testing, by = "record_id")

withdrawn_no_testing <- remaining_4 %>% filter(intervention_status == 4)
remaining_4 <- anti_join(remaining_4, withdrawn_no_testing, by = "record_id")

lost <- remaining_4 %>% filter(intervention_status == 5)
remaining_4 <- anti_join(remaining_4, lost, by = "record_id")



##### Fourth part of consort diagram  #####
group_1 <- randomized %>% filter(group == 1)
remaining_4 <- anti_join(randomized, group_1, by = "record_id")

group_2 <- remaining_4 %>% filter(group == 2)
remaining_4 <- anti_join(remaining_4, group_2, by = "record_id")


##### Consort diagram language ######
screened_language <- paste0("Screened (n = ",nrow(screened),")")
eligible_language <- paste0("Eligible for Consent (n = ",nrow(eligible),")")
still_screening_language <- paste0("Still Screening (n = ",nrow(on_hold) + nrow(still_screening),")")
screen_fail_language <- paste0("Screen Failed (n = ",nrow(screen_failed),")")

consented_language <- paste0("Consented (n = ",nrow(consented),")")
in_process_language <- paste0("Expected to Consent \n(n = ",nrow(expected_to_consent),")")

randomized_language <- paste0("Randomized (n = ",nrow(randomized),")")
in_baseline_language <- paste0("In Baseline (n = ",nrow(in_baseline),")")
screen_failed_baseline_language <- paste0("Screen Failed (n = ",nrow(screen_failed_after_consent),")")


group_1_language <- group_1_language <- paste0("Group ",group_1$random_group_letter[1],"\n (n = ",nrow(group_1),")")
group_2_language <- paste0("Group ",group_2$random_group_letter[1],"\n (n = ",nrow(group_2),")")


group_1_status_language <- paste0("Active (n = ",sum(group_1$intervention_status == 1 | is.na(group_1$intervention_status)),")\n",
                                 "Lost to follow-up (n = ",sum(group_1$intervention_status == 5, na.rm = T),")\n",
                                 "Withdrawn \n Unwilling to test (n = ",sum(group_1$intervention_status == 4, na.rm = T),")\n",
                                 "Willing to test (n = ",sum(group_1$intervention_status == 3, na.rm = T),")\n")
group_2_status_language <- paste0("Active (n = ",sum(group_2$intervention_status == 1 | is.na(group_2$intervention_status)),")\n",
                                 "Lost to follow-up (n = ",sum(group_2$intervention_status == 5, na.rm = T),")\n",
                                 "Withdrawn \n Unwilling to test (n = ",sum(group_2$intervention_status == 4, na.rm = T),")\n",
                                 "Willing to test (n = ",sum(group_2$intervention_status == 3, na.rm = T),")\n")


group_1_completed_language <- paste0("Completed\n (n = ",sum(group_1$intervention_status == 2, na.rm = T),")")
group_2_completed_language <- paste0("Completed\n (n = ",sum(group_2$intervention_status == 2, na.rm = T),")")

#### ggplot settings ####
font_size <- 3
font_size_smaller <- 2.5
line_size <- .3

#### Beginning Screening ggplot ####
data <- tibble(x= 30:150, y= 30:150)
data %>% 
  ggplot(aes(x, y)) + 
  xlim(-60,180) +
  theme_void() +
  ####### Adding Boxes
  geom_rect(xmin = 35, xmax=85, ymin=147, ymax=153, color='black',  #Screened
            fill='white', size=0.25) +
  geom_rect(xmin = 25, xmax=95, ymin=27, ymax=33, color='black',  #Eligible
            fill='white', size=0.25) +
  geom_rect(xmin = -30, xmax=30, ymin=107, ymax=113, color='black',  #Still Screening
            fill='white', size=0.25) +
  geom_rect(xmin = 90, xmax=170, ymin=40, ymax=145, color='black',  #Screen Failed
            fill='white', size=0.25) -> p
  ###### Writing Lettering
p +
  annotate('text', x= 60, y=150,label= screened_language, size=font_size) +  #Screened
  annotate('text', x= 60, y=30,label= eligible_language, size=font_size) +   #Eligible
  annotate('text', x= 0, y=110,label= still_screening_language, size=font_size) +  #Still Screening
  annotate('text', x=130 , y=140,label= screen_fail_language, size=font_size) + #Screen Failed Number
  annotate('text', x=130 , y=88,label= string, size=font_size_smaller) -> p    #Screen Failed reason
###### Adding arrows
p +
  geom_segment(
    x=60, xend=60, y=147, yend=33.5, 
    size=line_size, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) + #screened to eligible
  geom_segment(
    x=60, xend=30.5, y=110, yend=110, 
    size=line_size, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) +  #middle to still screening
  geom_segment(
    x=60, xend=89.5, y=110, yend=110, 
    size=line_size, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) -> p #screened to screen failed
p
ggsave(file.path(data_dir,'dsmc_report','closed_consort_screen.png'), p, scale = 1,width = 6.92, height = 5, units = "in")

#### Beginning Enrolled ggplot####
data <- tibble(x= -50:50, y= -50:50)
data %>%
  ggplot(aes(x, y)) +
  ylim(-60,50) +
  xlim(-60,198) +
  #scale_x_continuous(breaks=seq(-60,225,5)) +
  theme_void() +
  ####### Adding Boxes
  geom_rect(xmin = 25, xmax=95, ymin=47, ymax=53, color='black',  #Eligible
            fill='white', size=0.25) +
  geom_rect(xmin = -22, xmax=22, ymin=32, ymax=44, color='black',  #Scheduled
            fill='white', size=0.25) +
  geom_rect(xmin = 40, xmax=80, ymin=22, ymax=28, color='black',  #Consented
            fill='white', size=0.25) +
  geom_rect(xmin = 38, xmax=82, ymin=-13, ymax=-7, color='black',  #Randomized
            fill='white', size=0.25) +
  geom_rect(xmin = -20, xmax=20, ymin=9, ymax=15, color='black',  #In Baseline
            fill='white', size=0.25) +
  geom_rect(xmin = 88, xmax=153, ymin=-5, ymax=25, color='black',  #Screen Failed Baseline
            fill='white', size=0.25) +
  #geom_rect(xmin = -56, xmax=-24, ymin=-17, ymax=-23, color='black',  #Core and fusion group
  #          fill='white', size=0.25) +
  geom_rect(xmin = 14, xmax=46, ymin=-17, ymax=-23, color='black',  #group_2 group
            fill='white', size=0.25) +
  geom_rect(xmin = 84, xmax=116, ymin=-17, ymax=-23, color='black',  #Resistance group
          fill='white', size=0.25) +
  #geom_rect(xmin = 144, xmax=176, ymin=-17, ymax=-23, color='black',  #Combo group
  #          fill='white', size=0.25) +
  #geom_rect(xmin = -35, xmax=5, ymin=-25, ymax=-40, color='black',  #Core and fusion status
   #         fill='white', size=0.25) + 
  geom_rect(xmin = 35, xmax=75, ymin=-25, ymax=-40, color='black',  #group_2 status
            fill='white', size=0.25) +
  geom_rect(xmin = 105, xmax=145, ymin=-25, ymax=-40, color='black',  #Resistance status
            fill='white', size=0.25) +
  #geom_rect(xmin = 165, xmax=205, ymin=-25, ymax=-40, color='black',  #Combo status
   #         fill='white', size=0.25) +
  #geom_rect(xmin = -56, xmax=-24, ymin=-42, ymax=-48, color='black',  #Core and fusion completed
   #         fill='white', size=0.25) +
  geom_rect(xmin = 14, xmax=46, ymin=-42, ymax=-48, color='black',  #group_2 completed
            fill='white', size=0.25) +
  geom_rect(xmin = 84, xmax=116, ymin=-42, ymax=-48, color='black',  #Resistance completed
            fill='white', size=0.25) -> p
  #geom_rect(xmin = 144, xmax=176, ymin=-42, ymax=-48, color='black',  #Combo completed
   #         fill='white', size=0.25)-> p
  
###### Writing Lettering
p +
  annotate('text', x= 60, y=50,label= eligible_language, size=font_size) +   #Eligible
  annotate('text', x= 60, y=25,label= consented_language, size=font_size) +    #Consented
  annotate('text', x= 0, y=38,label= in_process_language, size=font_size) +  #Scheduled to consent
  annotate('text', x= 60, y=-10,label= randomized_language, size=font_size) +  #Randomized
  annotate('text', x= 0, y=12,label= in_baseline_language, size=font_size) + #In baseline
  annotate('text', x=120 , y=23, label= screen_failed_baseline_language, size=font_size) + #Screen failed number
  annotate('text', x=120 , y=8,label= string_2, size=font_size_smaller) + #Screen Failed reasons after baseline
  #annotate('text', x=-40 , y=-20,label= group_1_language, size=font_size) + #Core & Fusion
  annotate('text', x=30 , y=-20,label= group_2_language, size=font_size) + #group_2 Group
  annotate('text', x=100 , y=-20,label= group_1_language, size=font_size) + #group_1 Group
  #annotate('text', x=160 , y=-20,label= combo_language, size=font_size) + #Combo Group
  #annotate('text', x=-15 , y=-33,label= group_1_status_language, size=font_size_smaller) + #group_1 Status Box
  annotate('text', x=55 , y=-33,label= group_2_status_language, size=font_size_smaller) + #group_2 status box
  annotate('text', x=125 , y=-33,label= group_1_status_language, size=font_size_smaller) + #group_1 status box
  #annotate('text', x=185 , y=-33,label= combo_status_language, size=font_size_smaller) + #Combo status box
  #annotate('text', x=-40 , y=-45,label= group_1_completed_language, size=font_size) + #group_1 Completed
  annotate('text', x=30 , y=-45,label= group_2_completed_language, size=font_size) + #group_2 Completed
  annotate('text', x=100 , y=-45,label= group_1_completed_language, size=font_size) -> p #Resistance Completed
  #annotate('text', x=160 , y=-45,label= combo_completed_language, size=font_size) -> p  #Combo Completed
  
###### Adding arrows
p +
  geom_segment(
    x=60, xend=60, y=47, yend=28.5,
    size=line_size, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) + #eligible for consent to consented
  geom_segment(
    x=60, xend=22.5, y=38, yend=38,
    size=line_size, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) + #eligible for consent to scheduled to consent
  geom_segment(
    x=60, xend=60, y=22, yend=-6.5,
    size=line_size, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) +  #consented to randomized
  geom_segment(
    x=60, xend=20.5, y=12, yend=12,
    size=line_size, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) + #Consented to in baseline
  geom_segment(
    x=60, xend=87.5, y=12, yend=12,
    size=line_size, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) + #Consented to Screen failed in baseline
  geom_segment(
    x=60, xend=60, y=-13, yend=-15,
    size=line_size, linejoin = "mitre", lineend = "butt") + #Joiner between randomized and horizontal line
  geom_segment(
    x=30, xend=100, y=-15, yend=-15,
    size=line_size, linejoin = "mitre", lineend = "butt") + #Horizontal line above statuses
  #geom_segment(
  #  x=-40, xend=-40, y=-15, yend=-17,
  #  size=line_size, linejoin = "mitre", lineend = "butt") + #Joiner between horizontal line and C&F
  geom_segment(
    x=30, xend=30, y=-15, yend=-17,
    size=line_size, linejoin = "mitre", lineend = "butt") + #Joiner between horizontal line and group_2
  geom_segment(
    x=100, xend=100, y=-15, yend=-17,
    size=line_size, linejoin = "mitre", lineend = "butt") + #Joiner between horizontal line and Resistance
  #geom_segment(
  #  x=160, xend=160, y=-15, yend=-17,
  #  size=line_size, linejoin = "mitre", lineend = "butt") +  #Joiner between  horizontal line and Combo
  #geom_segment(
  #  x=-40, xend=-40, y=-23, yend=-41,
  #  size=line_size, linejoin = "mitre", lineend = "butt",
   # arrow = arrow(length = unit(1, "mm"), type= "closed")) +
  geom_segment(
    x=30, xend=30, y=-23, yend=-41,
    size=line_size, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) +
  geom_segment(
    x=100, xend=100, y=-23, yend=-41,
    size=line_size, linejoin = "mitre", lineend = "butt",
    arrow = arrow(length = unit(1, "mm"), type= "closed")) -> p
  #geom_segment(
   # x=160, xend=160, y=-23, yend=-41,
    #size=line_size, linejoin = "mitre", lineend = "butt",
    #arrow = arrow(length = unit(1, "mm"), type= "closed")) -> p
  
p
ggsave(file.path(data_dir,'dsmc_report','closed_consort_enrolled.png'), p, scale = 1.1,width = 6.92, height = 6.92, units = "in")





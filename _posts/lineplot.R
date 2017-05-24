# Libraries

library(ggplot2)
library(gtable)
library(grid)
library(extrafont)

# Data
dat = read.csv(text = ",Russia,World
               1996,0,423
               1997,4,220
               1998,1,221
               1999,0,298
               2000,0,322
               2001,8,530
               2002,6,466
               2003,17,459
               2004,25,562
               2005,27,664
               2006,33,760
               2007,53,893
               2008,87,1038
               2009,32,761
               2010,62,949
               2011,101,1109
               2012,96,1130
               2013,110,1317
               2014,111,1535
               2015,88,1738", header  = TRUE)

dat <- read.csv("billionaire.csv")
rus <- dat[,1:2]
world <- dat[,-2]

# Create p1
p1 <- ggplot(rus, aes(X, Russia)) + 
  geom_line(colour = "#68382C", size = 1.5) + 
  #ggtitle("Number in Russia\n") +
  labs(x=NULL,y=NULL) +
  scale_x_continuous(breaks= c(1996, seq(2000,2015,5))) +
  scale_y_continuous(expand = c(0, 0), limits = c(0,200)) +
  theme(
    panel.background = element_blank(),
    panel.grid.minor = element_blank(), 
    panel.grid.major = element_line(color = "gray50", size = 0.75),
    panel.grid.major.x = element_blank(),
    text = element_text(family="ITCOfficinaSans LT Book"),
    axis.text.y = element_text(colour="#68382C", size = 14),
    axis.text.x = element_text(size = 14, colour = "black"),
    axis.ticks = element_line(colour = 'gray50'),
    axis.ticks.length = unit(.2, "cm"),
    axis.ticks.x = element_line(colour = "black"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(hjust = -0.135, vjust=2.12, colour="#68382C", size = 14, family = "OfficinaSanITCMedium")) 

# Create p2
p2 <- ggplot(world, aes(X, World)) + 
  geom_line(colour = "#00A4E6", size = 1.5) +  
  #ggtitle("Rest of world\n") +
  labs(x=NULL,y=NULL) +
  scale_y_continuous(expand = c(0, 0), limits = c(0,2000)) +
  theme(
    panel.background = element_blank(),
    panel.grid.minor = element_blank(), 
    panel.grid.major = element_blank(),
    text = element_text(family="ITCOfficinaSans LT Book"),
    axis.text.y = element_text(colour="#00A4E6", size=14),
    axis.text.x = element_text(size=14),
    axis.ticks.length = unit(.2, "cm"),
    axis.ticks.y = element_blank(),
    plot.title = element_text(hjust = 0.6, vjust=2.12, colour = "#00a4e6", size = 14, family = "OfficinaSanITCMedium"))

# Get the plot grobs
g1 <- ggplotGrob(p1)
g2 <- ggplotGrob(p2)

# Get the locations of the plot panels in g1.
pp <- c(subset(g1$layout, name == "panel", se = t:r))

# Overlap panel for second plot on that of the first plot
g1 <- gtable_add_grob(g1, g2$grobs[[which(g2$layout$name == "panel")]], pp$t, pp$l, pp$b, pp$l)

# ggplot contains many labels that are themselves complex grob; 
# usually a text grob surrounded by margins.
# When moving the grobs from, say, the left to the right of a plot,
# make sure the margins and the justifications are swapped around.
# The function below does the swapping.
# Taken from the cowplot package:
# https://github.com/wilkelab/cowplot/blob/master/R/switch_axis.R 
hinvert_title_grob <- function(grob){
  
  # Swap the widths
  widths <- grob$widths
  grob$widths[1] <- widths[3]
  grob$widths[3] <- widths[1]
  grob$vp[[1]]$layout$widths[1] <- widths[3]
  grob$vp[[1]]$layout$widths[3] <- widths[1]
  
  # Fix the justification
  grob$children[[1]]$hjust <- 1 - grob$children[[1]]$hjust 
  grob$children[[1]]$vjust <- 1 - grob$children[[1]]$vjust 
  grob$children[[1]]$x <- unit(1, "npc") - grob$children[[1]]$x
  grob
}

# Get the y axis from g2 (axis line, tick marks, and tick mark labels)
index <- which(g2$layout$name == "axis-l")  # Which grob
yaxis <- g2$grobs[[index]]                  # Extract the grob

# yaxis is a complex of grobs containing the axis line, the tick marks, and the tick mark labels.
# The relevant grobs are contained in axis$children:
#   axis$children[[1]] contains the axis line;
#   axis$children[[2]] contains the tick marks and tick mark labels.

# Second, swap tick marks and tick mark labels
ticks <- yaxis$children[[2]]
ticks$widths <- rev(ticks$widths)
ticks$grobs <- rev(ticks$grobs)

# Third, move the tick marks
# Tick mark lengths can change. 
# A function to get the original tick mark length
# Taken from the cowplot package:
# https://github.com/wilkelab/cowplot/blob/master/R/switch_axis.R 
plot_theme <- function(p) {
  plyr::defaults(p$theme, theme_get())
}

tml <- plot_theme(p1)$axis.ticks.length   # Tick mark length
ticks$grobs[[1]]$x <- ticks$grobs[[1]]$x - unit(1, "npc") + tml

# Fourth, swap margins and fix justifications for the tick mark labels
ticks$grobs[[2]] <- hinvert_title_grob(ticks$grobs[[2]])

# Fifth, put ticks back into yaxis
yaxis$children[[2]] <- ticks

# Put the transformed yaxis on the right side of g1
g1 <- gtable_add_cols(g1, g2$widths[g2$layout[index, ]$l], pp$r)
g1 <- gtable_add_grob(g1, yaxis, pp$t, pp$r + 1, pp$b, pp$r + 1, clip = "off", name = "axis-r")

# Labels grob
left = textGrob("Number in Russia", x = 0, y = 0.9, just = c("left", "top"), gp = gpar(fontsize = 14, col =  "#68382C", fontfamily = "OfficinaSanITCMedium"))
right =  textGrob("Rest of world", x = 1, y = 0.9, just = c("right", "top"), gp = gpar(fontsize = 14, col =  "#00a4e6", fontfamily = "OfficinaSanITCMedium"))
labs = gTree("Labs", children = gList(left, right))

# New row in the gtable for labels
height = unit(3, "grobheight", left)
g1 <- gtable_add_rows(g1, height, 2)  

# Put the label in the new row
g1 = gtable_add_grob(g1, labs, t=3, l=3, r=5)

# Turn off clipping in the plot panel
g1$layout[which(g1$layout$name == "panel"), ]$clip = "off"

# Print it to PDF
ggsave("plot.pdf", g1, width=5, height=5)
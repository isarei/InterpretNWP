#for little more documentation see WorldPlotsExpectiles

rm(list=ls())

library(tidyverse)
library(maptools)
library(maps)
library(ggmap)
library(ggplot2)

#directory
setwd('~/Documents/UNI/Master/Masterarbeit/Daten/Ergebnisse/ResultsCompleteInstrumentsLag2')
load('Res_quantiles_mean16.Rdata')

#World
WorldData <- map_data('world')
WorldData <- fortify(WorldData)

#filter -40-40 latitude
res_quantiles_mean16 <- res_quantiles_mean16 %>% filter(lat>=-40) %>% filter(lat<=40)

#testniveau
alpha=0.05

#p_opt discrete
pos <- res_quantiles_mean16 %>% filter(p_opt>=alpha)
neg <- res_quantiles_mean16 %>% filter(p_opt<alpha)
p_opt_disc <- ggplot() +
  geom_point(aes(x = pos$lon, y = pos$lat, 
                 color = paste("\u2265", alpha, sep=' ')),
             size=0.5, shape  = 15) + 
  geom_point(aes(x = neg$lon, y = neg$lat, 
                 color = paste('<',alpha,sep=' ')),
             size=0.5, shape  = 15) + 
  geom_map(data=WorldData, map=WorldData,
           aes(x=long, y=lat, group=group, map_id=region),
           fill=NA, colour="black", size=0.2) +
  xlim(-180,180) +
  theme(panel.background = element_rect(fill = "gray80"),
        legend.position=c(0.934,0.895),
        #legend.title = element_blank(),
        legend.background = element_rect(color = "black", fill = "gray80", 
                                         size = 0.5, linetype = "solid"),
        #legend.direction = "horizontal", 
        legend.key = element_rect(fill = "gray80", color = NaN),
        legend.text.align = 0,
        legend.key.size = unit(0.1,"cm"),
        legend.key.width=unit(0.1,"cm")) +
  guides(colour = guide_legend(override.aes = list(size=4))) + 
  #ylim(-50,50) +
  labs(#title="p-value in the case of quantiles"
    x='longitude', y="latitude", col='p-value') #+
  #theme(legend.text=element_text(size=13), axis.text = element_text(size = 17))

#p_opt cont
p_opt_cont <- ggplot() +
  geom_point(aes(x = res_quantiles_mean16$lon, y = res_quantiles_mean16$lat, 
                 color = res_quantiles_mean16$p_opt),
             size=0.5, shape  = 15) + 
  scale_color_gradientn(colours = rainbow(5), na.value = "white") +
  geom_map(data=WorldData, map=WorldData,
           aes(x=long, y=lat, group=group, map_id=region),
           fill=NA, colour="black", size=0.2) +
  xlim(-180,180) +
  theme(panel.background = element_rect(fill = "gray80")) + 
  #ylim(-50,50) +
  labs(#title="Estimated intercept in the case of expectiles",
    x='longitude', y="latitude", col=bquote(p[opt])) +
  theme(legend.text=element_text(size=15), axis.text = element_text(size = 15))


#pWald discrete
pos2 <- res_quantiles_mean16 %>% filter(p_wald>=alpha)
neg2 <- res_quantiles_mean16 %>% filter(p_wald<alpha)

p_wald_disc <- ggplot() +
  geom_point(aes(x = pos2$lon, y = pos2$lat, 
                 color = paste("\u2265", alpha, sep=' ')),
             size=0.5, shape  = 15) + 
  geom_point(aes(x = neg2$lon, y = neg2$lat, 
                 color = paste('<', alpha, sep=' ')),
             size=0.5, shape  = 15) + 
  geom_map(data=WorldData, map=WorldData,
           aes(x=long, y=lat, group=group, map_id=region),
           fill=NA, colour="black", size=0.2) +
  xlim(-180,180) +
  theme(panel.background = element_rect(fill = "gray80"),
        legend.position=c(0.934,0.895),
        #legend.title = element_blank(),
        legend.background = element_rect(color = "black", fill = "gray80", 
                                         size = 0.5, linetype = "solid"),
        #legend.direction = "horizontal", 
        legend.key = element_rect(fill = "gray80", color = NaN),
        legend.text.align = 0,
        legend.key.size = unit(0.1,"cm"),
        legend.key.width=unit(0.1,"cm")) +
  guides(colour = guide_legend(override.aes = list(size=4))) + 
  #ylim(-50,50) +
  labs(#title="p-value of Wald-Test in the case of quantiles",
    x='longitude', y="latitude", col='p-value')

##filter
restr <- res_quantiles_mean16 %>% filter(p_opt>=alpha) %>% 
  filter(p_wald<alpha) 

#restricted coordinates
map_restr <- ggplot() +
  geom_point(aes(x = restr$lon, y = restr$lat), col='skyblue2', size=0.5, shape=15) +
  geom_map(data=WorldData, map=WorldData,
           aes(x=long, y=lat, group=group, map_id=region),
           fill=NA, colour="black", size=0.2) +
  theme(panel.background = element_rect(fill = "gray80")) + 
  labs(x='longitude', y="latitude") +
  xlim(-180,180) 
  #ylim(-50,50)
  

#Slope
slope <- ggplot() +
  geom_point(aes(x = restr$lon, y = restr16$lat, 
                 color = restr$theta2), size=0.5, shape=15) + 
  scale_colour_gradient2(low = "red", mid = "white", 
                         high = "blue", midpoint = 0, space = "Lab", 
                         limits = c(-1,1),
                         oob = scales::squish,
                         na.value = "grey50", guide = "colourbar", aesthetics = "colour") +
  geom_map(data=WorldData, map=WorldData,
           aes(x=long, y=lat, group=group, map_id=region),
           fill=NA, colour="black", size=0.2) +
  xlim(-180,180) +
  theme(panel.background = element_rect(fill = "gray80")) + 
  labs(title="Estimated slope in the case of quantiles",
       x='longitude', y="latitude", col=bquote(theta[2]))

#Intercept
#Calculate Phi(theta1) and add it as column to data frame --> theta_new
phi_of_theta1 <- sapply(restr$theta1, pnorm)
new <- cbind(restr, phi_of_theta1)
intercept <- ggplot() +
  geom_point(aes(x = new$lon, y = new$lat, color = phi_of_theta1),
             size=0.5, shape  = 15) + 
  scale_color_gradientn(colours = rainbow(5)) +
  geom_map(data=WorldData, map=WorldData,
           aes(x=long, y=lat, group=group, map_id=region),
           fill=NA, colour="black", size=0.2) +
  xlim(-180,180) +
  theme(panel.background = element_rect(fill = "gray80")) + 
  #ylim(-50,50) +
  labs(title="Estimated intercept in the case of quantiles",
       x='longitude', y="latitude", col=bquote(Phi(theta[1])))

#Estimated Forc lel at mean and 90 percetile
dotsize <- 0.2
arg_ninety <- restr$theta1 + restr$theta2*restr$s_ninety
arg_mean <- restr$theta1 + restr$theta2*restr$s_mean
phi_of_arg_ninety <- sapply(arg_ninety, pnorm)
phi_of_arg_mean <- sapply(arg_mean, pnorm)
theta_new_ninety <- cbind(restr, phi_of_arg_ninety)
theta_new_mean <- cbind(restr, phi_of_arg_mean)

map_ninety <- ggplot() +
  geom_point(aes(x = theta_new_ninety$lon, y = theta_new_ninety$lat, color = phi_of_arg_ninety),
             size=dotsize, shape  = 15) + 
  scale_color_gradientn(colours = rainbow(5)) +
  geom_map(data=WorldData, map=WorldData,
           aes(x=long, y=lat, group=group, map_id=region),
           fill=NA, colour="black", size=0.2) +
  xlim(-180,180) +
  theme(panel.background = element_rect(fill = "gray80")) + 
  #ylim(-50,50) +
  labs(#title="Forecast level at 90 percentile in the case of expectiles (Restricted)",
    x='longitude', y="latitude", col=bquote(Phi(theta[1]+theta[2]*(s[(90)]))))

map_mean <- ggplot() +
  geom_point(aes(x = theta_new_mean$lon, y = theta_new_mean$lat, color = phi_of_arg_mean),
             size=dotsize, shape  = 15) + 
  scale_color_gradientn(colours = rainbow(5)) +
  geom_map(data=WorldData, map=WorldData,
           aes(x=long, y=lat, group=group, map_id=region),
           fill=NA, colour="black", size=0.2) +
  xlim(-180,180) +
  theme(panel.background = element_rect(fill = "gray80")) + 
  #ylim(-50,50) +
  labs(#title="Forecast level at 90 percentile in the case of expectiles (Restricted)",
    x='longitude', y="latitude", col=bquote(Phi(theta[1]+theta[2]*bar(s))))

ggsave(plot=p_opt_disc, filename = '../../../Tex/p_opt_disc_q_005.pdf', 
       device = cairo_pdf, width=6.38, height=3.89,units='in')
ggsave(plot=p_wald_disc, filename = '../../../Tex/p_wald_disc_q_005.pdf', 
       device = cairo_pdf, width=6.38, height=3.89,units='in')
ggsave(plot=map_restr, filename = '../../../Tex/restr_q_005.pdf', 
       device = cairo_pdf, width=6.38, height=3.89,units='in')

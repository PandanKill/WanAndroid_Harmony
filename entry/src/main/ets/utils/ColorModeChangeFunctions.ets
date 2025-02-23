import { common, ConfigurationConstant } from '@kit.AbilityKit'

const setColorMode = (context: common.UIAbilityContext, colorMode: ConfigurationConstant.ColorMode) => {
  context.getApplicationContext().setColorMode(colorMode)
}

export const setAutoColorMode = (context: common.UIAbilityContext) => {
  setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
}

export const setLightColorMode = (context: common.UIAbilityContext) => {
  setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
}

export const setDarkColorMode = (context: common.UIAbilityContext) => {
  setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
}
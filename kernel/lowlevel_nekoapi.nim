proc cli*() =
  ## Disable Interrupts
  asm """
    cli
  """

proc sti*() =
  ## Enable Interrupts
  asm """
    sti
  """

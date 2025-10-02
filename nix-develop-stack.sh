if [[ -n "$NIX_DEVELOP_STACK" ]]; then
  export NIX_DEVELOP_STACK="$NIX_DEVELOP_STACK|$NAME"
else
  export NIX_DEVELOP_STACK="$NAME"
fi

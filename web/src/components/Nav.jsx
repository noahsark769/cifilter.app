import React from 'react';
import styled from 'styled-components';
import Logo from './Logo';

const LogoWrapper = styled.div`
    display: block;
    width: 30px;
    height: 30px;
`;

const StyledNav = styled.nav`
    width: 100%;
`;

const Nav = (props) => {
    return (
        <StyledNav className="padding--md">
            <LogoWrapper><Logo /></LogoWrapper>
        </StyledNav>
    )
};
export default Nav;